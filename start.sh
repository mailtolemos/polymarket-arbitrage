#!/bin/sh
# Railway injects $PORT at runtime. Default to 8080 for local docker runs.
exec python run_with_dashboard.py --port "${PORT:-8080}"
