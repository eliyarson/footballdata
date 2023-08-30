FROM python:3.10.7-slim-bullseye

WORKDIR /workspace

COPY . .

RUN python3 -m pip install --no-cache-dir -r requirements.txt

ENV FOOTBALLAPI_KEY=9330156cad575b8912db6160ea6996c141b34358eb69d32a8b3676b6a07b914c

ENTRYPOINT ["python3","main.py"]