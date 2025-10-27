# Dockerfile
FROM python:3.11
COPY requirements.txt /orderapp/requirements.txt
WORKDIR /orderapp
RUN pip install --no-cache-dir -r requirements.txt
COPY . /orderapp
ENTRYPOINT ["python"]
CMD ["run.py"]