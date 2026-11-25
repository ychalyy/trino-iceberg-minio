#!/usr/bin/env python3
"""Run the same SQL steps manually or as one idempotent Lakehouse batch."""
import argparse
import fcntl
import hashlib
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import time
import uuid

ROOT = Path(__file__).resolve().parents[1]
SQL = ROOT / "sql" / "pipeline"
CLI = ["docker", "compose", "exec", "-T", "trino", "trino", "--output-format", "TSV"]
SEQUENCE = {"initial": 1, "delta": 2, "invalid": 3}
PARAMETER = re.compile(r"@([a-z_]+)@")
RUN_ID = re.compile(r"[A-Za-z0-9_-]{1,80}")
RESULTS = "iceberg.ops.dq_results"

class LoadError(Exception):
    pass

class DemonstrationStop(LoadError):
    pass

def log(message):
    print(message, flush=True)
    journal = os.environ.get("LAKEHOUSE_EXEC_JOURNAL")
    if journal:
        with Path(journal).open("a", encoding="utf-8") as stream:
            fcntl.flock(stream, fcntl.LOCK_EX)
            stream.write(f"\n{message}\n")

def execute(query, description, file=None, params=None, trace=True, retry_commit=False):
    command = [*CLI, "--file", "/dev/stdin"] if file else [*CLI, "--execute", query]
    # Template parameters are deliberately restricted to batch names, integers, and run IDs.
    details = f"  # stdin: {file.relative_to(ROOT)}" if file else ""
    if params and file:
        details += "; " + ", ".join(f"{k}={v}" for k, v in params.items())
    if trace:
        log(f"**Зачем и что делает.** {description}\n\n"
            f"```sh\n{shlex.join(command)}{details}\n```")
    for attempt in range(3 if retry_commit else 1):
        result = subprocess.run(command, cwd=ROOT, input=query if file else None, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output = result.stdout + result.stderr
        if trace or result.returncode:
            log(f"**Результат.** Код {result.returncode}.\n\n"
                f"```text\n{output.strip()[:3500]}\n```")
        if not result.returncode:
            break
        uncertain = ("Cannot determine whether the commit" in output
                     or "SQLITE_BUSY" in output
                     or "SQLITE_LOCKED" in output)
        if not retry_commit or not uncertain or attempt == 2:
            raise LoadError(f"Trino exited {result.returncode}")
        log(f"**Повтор.** Неясный результат коммита. Повтор идемпотентного SQL через {2 ** attempt} с.")
        time.sleep(2 ** attempt)
    return result.stdout.strip()

def step(name, description, batch=None, run_id=None):
    path = SQL / name
    params = {} if batch is None else {"batch_seq": SEQUENCE[batch], "batch_id": batch, "run_id": run_id}
    query = PARAMETER.sub(lambda m: str(params[m[1]]), path.read_text(encoding="utf-8"))
    execute(query, description, path, params, retry_commit=True)

def bootstrap():
    step("00-schema.sql", "Создаёт схемы и таблицы Iceberg, если их ещё нет.")
    step("10-source.sql", "Подключает типизированные представления источника и демонстрационную дельту.")
    step("40-marts.sql", "Создаёт расчётные представления по истории Vault и эталонному Raw.")
    missing = execute("""SELECT batch_id FROM iceberg.ops.batches b
WHERE status='COMPLETE'
  AND (NOT EXISTS (SELECT 1 FROM iceberg.mart.sales_snapshot s WHERE s.batch_seq=b.batch_seq)
       OR NOT EXISTS (SELECT 1 FROM iceberg.mart.shipping_snapshot s WHERE s.batch_seq=b.batch_seq))
ORDER BY batch_seq""", "Проверяет наличие агрегатов для ранее опубликованных пакетов.", trace=False)
    for batch in missing.splitlines():
        materialize(batch, None)
    step("46-public-marts.sql", "Публикует представления поверх снимков завершённых пакетов.")

def batch_status(batch):
    return execute(
        f"SELECT status FROM iceberg.ops.batches WHERE batch_seq={SEQUENCE[batch]}",
        "Проверяет существование и состояние пакета.", trace=False,
    )

def register(batch):
    if batch == "invalid":
        raise LoadError("The invalid fixture is used only for input DQ")
    if batch == "delta" and batch_status("initial") != "COMPLETE":
        raise LoadError("Complete initial before delta")
    seq = SEQUENCE[batch]
    execute(f"""MERGE INTO iceberg.ops.batches t
USING (VALUES ({seq}, '{batch}', current_timestamp(6), 'PENDING')) s(batch_seq,batch_id,loaded_at,status)
ON t.batch_seq=s.batch_seq
WHEN NOT MATCHED THEN INSERT (batch_seq,batch_id,loaded_at,status)
VALUES (s.batch_seq,s.batch_id,s.loaded_at,s.status)""",
            "Регистрирует пакет один раз и сохраняет исходное время загрузки для повторов.", retry_commit=True)

def quality(phase, batch, run_id):
    conflicting = execute(f"SELECT count(*) FROM {RESULTS} WHERE run_id='{run_id}' AND batch_id<>'{batch}'",
                          "Проверяет привязку идентификатора попытки к пакету.", trace=False)
    if conflicting != "0":
        raise LoadError("Run ID already belongs to another batch")
    if phase == "input":
        step("50-input-dq.sql", "Проверяет восемь входных наборов, ключи, связи и диапазон скидок.", batch, run_id)
    else:
        step("60-model-dq.sql", "Группами сверяет Raw, структуру Vault и витрины с независимым расчётом.", batch, run_id)
    counts = execute(
        f"SELECT status, count(*) FROM {RESULTS} WHERE run_id='{run_id}' AND phase='{phase}' GROUP BY status ORDER BY status",
        "Выводит число пройденных и проваленных правил для текущей попытки.",
    )
    if not counts or "FAIL\t" in counts:
        execute(f"""SELECT rule_id, object_name, expected_value, actual_value
FROM {RESULTS} WHERE run_id='{run_id}' AND phase='{phase}' AND status='FAIL' ORDER BY rule_id, object_name""",
                "Показывает причины отклонения текущей попытки.")
        raise LoadError(f"{phase} DQ failed (run={run_id}, batch={batch})")

def raw(batch, run_id):
    step("20-raw.sql", "Записывает Raw по ключу исходной строки и номеру пакета.", batch, run_id)

def vault(batch, run_id):
    step("30-vault.sql", "Записывает бизнес-ключи, связи и только новые версии сателлитов.", batch, run_id)

def materialize(batch, run_id):
    step("45-mart-snapshots.sql", "Записывает агрегаты обеих витрин по ключу группы и пакету.", batch, run_id)

def require_passed(phase, batch, run_id):
    result = execute(f"""SELECT IF(count(*) > 0 AND count_if(status='FAIL') = 0, 'PASS', 'BLOCKED')
FROM {RESULTS} WHERE run_id='{run_id}' AND batch_id='{batch}' AND phase='{phase}'""",
                     "Проверяет, что требуемая фаза DQ пройдена.", trace=False)
    if result != "PASS":
        raise LoadError(f"{phase} DQ must pass for {batch} / {run_id}")

def publish(batch, run_id):
    if batch == "invalid":
        raise LoadError("Invalid fixture cannot be published")
    require_passed("input", batch, run_id)
    require_passed("model", batch, run_id)
    execute(f"UPDATE iceberg.ops.batches SET status='COMPLETE' WHERE batch_seq={SEQUENCE[batch]} AND status='PENDING'",
            "Атомарно публикует проверенный пакет: обе витрины получают один и тот же номер пакета.", retry_commit=True)

def load(batch, stop_after_raw=False):
    run_id = uuid.uuid4().hex
    log(f"\n### Пакет {batch}, попытка {run_id}")
    previous = None
    if batch != "invalid":
        previous = batch_status(batch)
        if previous != "COMPLETE":
            register(batch)
    quality("input", batch, run_id)
    if batch == "invalid":
        raise LoadError("Expected invalid fixture to fail input DQ")
    if previous != "COMPLETE":
        raw(batch, run_id)
        if stop_after_raw:
            raise DemonstrationStop("Demonstration stop after writing Raw")
        vault(batch, run_id)
        materialize(batch, run_id)
    quality("model", batch, run_id)
    if previous != "COMPLETE":
        publish(batch, run_id)

def current():
    batch = execute("""SELECT batch_id FROM iceberg.ops.batches
WHERE status='COMPLETE' ORDER BY batch_seq DESC LIMIT 1""",
                    "Определяет последний опубликованный пакет.", trace=False)
    if not batch:
        raise LoadError("No complete package. Load initial first.")
    return batch

def data_signature(view):
    rows = execute(f"SELECT * FROM iceberg.mart.{view} ORDER BY 2,3",
                   "Считывает отсортированные значения витрины.", trace=False)
    values = "\n".join(row.split("\t", 1)[1] for row in rows.splitlines())
    return hashlib.sha256(values.encode()).hexdigest()

def signatures():
    return [data_signature(view) for view in ("sales_by_region", "shipping_by_mode")]

def demand(condition, description):
    if not condition:
        raise LoadError(description)

def evidence():
    step("90-evidence.sql", "Показывает объёмы Raw, историю скидки, сверку витрин и итоги DQ.")

def demo():
    if batch_status("delta"):
        raise LoadError("Demo requires an isolated project before delta was registered")
    load("initial")
    before = signatures()
    load("initial")
    demand(signatures() == before, "Initial replay changed a mart")
    try:
        load("delta", stop_after_raw=True)
    except DemonstrationStop:
        demand(signatures() == before, "Unpublished delta changed a mart")
    else:
        raise LoadError("Expected a stop after Raw")
    load("delta")
    after = signatures()
    demand(after[0] != before[0] and after[1] == before[1], "Unexpected result of the discount change")
    load("delta")
    demand(signatures() == after, "Delta replay changed a mart")
    try:
        load("invalid")
    except LoadError as error:
        if "input DQ failed" not in str(error):
            raise
        demand(signatures() == after, "Rejected input changed a mart")
    else:
        raise LoadError("Invalid package should fail")
    evidence()
    log("**Итог демонстрации.** Повторы, восстановление и отклонение ошибочного пакета проверены.")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("bootstrap", "load", "dq", "demo", "evidence", "register",
                        "input", "raw", "vault", "materialize", "model", "publish"))
    parser.add_argument("--batch", choices=SEQUENCE)
    parser.add_argument("--run-id", default="")
    parser.add_argument("--stop-after-raw", action="store_true")
    args = parser.parse_args()
    manual = {"register", "input", "raw", "vault", "materialize", "model", "publish"}
    if args.action in {*manual, "load"} and not args.batch:
        parser.error("--batch is required")
    if args.action in manual - {"register"} and not RUN_ID.fullmatch(args.run_id):
        parser.error("--run-id requires 1–80 letters, digits, underscores, or hyphens")
    project = os.environ.get("COMPOSE_PROJECT_NAME", ROOT.name)
    lock_id = hashlib.sha256(project.encode()).hexdigest()[:16]
    with (Path(os.environ.get("TMPDIR", "/tmp")) / f"lakehouse-{lock_id}.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise LoadError("Another load is running for this Compose project") from error
        if args.action in {"bootstrap","load","dq","demo"}:
            bootstrap()
        if args.action == "load":
            load(args.batch, args.stop_after_raw)
        elif args.action == "dq":
            batch = current()
            run_id = uuid.uuid4().hex
            quality("input", batch, run_id)
            quality("model", batch, run_id)
        elif args.action == "demo":
            demo()
        elif args.action == "evidence":
            evidence()
        elif args.action == "register":
            register(args.batch)
        elif args.action in {"input", "model"}:
            quality(args.action, args.batch, args.run_id)
        elif args.action in {"raw","vault","materialize","publish"}:
            if args.batch == "invalid" or not batch_status(args.batch):
                raise LoadError("Register a valid package before writing")
            require_passed("input", args.batch, args.run_id)
            if batch_status(args.batch) != "COMPLETE":
                {"raw": raw, "vault": vault, "materialize": materialize, "publish": publish}[args.action](args.batch, args.run_id)

if __name__ == "__main__":
    try:
        main()
    except (LoadError, OSError) as error:
        log(f"**Остановка.** {error}")
        sys.exit(1)
