# Dockerfile
FROM python:3.11
COPY requirements.txt /userapp/requirements.txt
WORKDIR /userapp
RUN pip install --no-cache-dir -r requirements.txt
COPY . /userapp
ENTRYPOINT ["python"]
CMD ["run.py"]