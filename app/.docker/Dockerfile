FROM python:3.10.7-slim-bullseye

WORKDIR /workspace

COPY . .

RUN python3 -m pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python3","main.py"]