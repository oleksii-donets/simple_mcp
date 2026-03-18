FROM python:3.12-slim

LABEL io.modelcontextprotocol.server.name="io.github.oleksii-donets/simple_mcp"

# Avoid Python writing .pyc files and ensure stdout/stderr are unbuffered
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Install curl and certificates to fetch uv, then install uv
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -LsSf https://astral.sh/uv/install.sh | sh

# Leverage layer caching: copy only dependency files first
COPY pyproject.toml uv.lock ./

# Install project dependencies into a virtualenv managed by uv
RUN uv sync --frozen --no-dev

# Now copy the rest of the source code
COPY . .

EXPOSE 3333

# Start the MCP server
CMD [".venv/bin/python", "main.py"]
