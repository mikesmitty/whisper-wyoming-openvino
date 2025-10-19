FROM ghcr.io/astral-sh/uv:python3.13-trixie-slim

ENV UV_SYSTEM_PYTHON=1

COPY ./wyoming-whisper-api-client /app

WORKDIR /app

RUN uv pip install -r /app/requirements.txt

RUN chmod +x run.sh

ENTRYPOINT ["bash", "/app/run.sh"]