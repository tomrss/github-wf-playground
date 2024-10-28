import logging
import os
from flask import Flask

app = Flask(__name__)

gunicorn_logger = logging.getLogger('gunicorn.error')
app.logger.handlers = gunicorn_logger.handlers
app.logger.setLevel(gunicorn_logger.level)


@app.route("/")
def index():
    env = os.getenv("APP_ENV", "UNKNOWN")
    app.logger.info(f"Requested index for env {env}")
    return f"""
    <h2>Welcome to GitHub Workflow Playground</h2>
    <h3>Azure App Service</h3>
    <p>Environment: <b>{env}</b>
    <br/>
    <p>Code is changed.</p>
    """


@app.route("/health")
def health():
    app.logger.debug("health OK")
    return {"status": "OK"}
