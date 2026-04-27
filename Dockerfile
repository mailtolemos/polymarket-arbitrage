# Railway-ready image for the polymarket-arbitrage bot + dashboard.
# Runs in simulation mode by default (see config.yaml).
FROM python:3.11-slim

# Avoid Python writing .pyc files and force unbuffered stdout for live logs.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Install dependencies first so this layer caches when only source changes.
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app.
COPY . .

# Create the logs directory the bot writes to.
RUN mkdir -p /app/logs

# Railway injects $PORT at runtime; default to 8080 for local docker runs.
ENV PORT=8080
EXPOSE 8080

# start.sh handles $PORT expansion regardless of how the runtime invokes CMD.
RUN chmod +x /app/start.sh
CMD ["/app/start.sh"]
