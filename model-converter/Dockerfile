FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

ENV UV_NO_CACHE=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Pre-install dependencies using uv
RUN uv pip install --system -r requirements.txt

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV HOME=/tmp

# Default command
CMD ["/bin/bash"]
