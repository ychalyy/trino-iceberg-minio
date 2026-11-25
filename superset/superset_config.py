import os

SECRET_KEY = os.environ["SUPERSET_SECRET_KEY"]
SQLALCHEMY_DATABASE_URI = "sqlite:////app/superset_home/superset.db"
SUPERSET_LOAD_EXAMPLES = False
ROW_LIMIT = 5000
