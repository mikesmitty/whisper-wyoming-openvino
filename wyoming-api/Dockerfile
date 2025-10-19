FROM ghcr.io/astral-sh/uv:python3.14-trixie-slim

ENV UV_NO_CACHE=1

ADD . /app

WORKDIR /app

RUN uv sync --locked

ENTRYPOINT ["uv", "run", "python", "-m", "wwac"]