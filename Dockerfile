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

# Railway injects $PORT at runtime; default to 8888 for local docker runs.
ENV PORT=8888
EXPOSE 8888

# Use shell form so $PORT expands. The dashboard already binds to 0.0.0.0
# in run_with_dashboard.py.
CMD python run_with_dashboard.py --port "${PORT}"
