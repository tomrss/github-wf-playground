import os
from flask import Flask

app = Flask(__name__)


@app.route("/")
def index():
    env = os.getenv("APP_ENV", "UNKNOWN")
    return f"""
    <h2>Welcome to GitHub Workflow Playground</h2>
    <h3>Azure App Service</h3>
    <p>Environment: <b>{env}</b>
    <br/>
    <p>Here are some changes in code!</p>
    """


@app.route("/health")
def health():
    return {"status": "OK"}
