FROM python:3.12

WORKDIR /work

RUN pip install pipenv gunicorn gevent

COPY Pipfile Pipfile
COPY Pipfile.lock Pipfile.lock
RUN pipenv install --system --deploy --ignore-pipfile

COPY app /work/app

EXPOSE 8080

USER 1001

ENTRYPOINT ["gunicorn"]
CMD ["app:app", "-w", "2", "-b", "0.0.0.0:8080"]

