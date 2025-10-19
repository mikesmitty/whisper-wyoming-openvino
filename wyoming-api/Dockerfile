FROM ghcr.io/astral-sh/uv:python3.13-trixie-slim

COPY ./wyoming-whisper-api-client /app

WORKDIR /app

RUN uv venv /app/.venv

ENV VIRTUAL_ENV=/app/.venv

RUN uv pip install -r /app/requirements.txt

RUN chmod +x run.sh

ENTRYPOINT ["uv", "run", "python", "wyoming_whisper_api_client"]