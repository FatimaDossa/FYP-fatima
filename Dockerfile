# Alkhidmat RAG API — production image for Railway
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONUTF8=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HUB_DISABLE_SYMLINKS_WARNING=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    tesseract-ocr \
    tesseract-ocr-eng \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
# Install deps except llama-cpp-python (use prebuilt wheel on Linux)
RUN grep -v "^llama-cpp-python" requirements.txt > /tmp/requirements-base.txt \
    && pip install -r /tmp/requirements-base.txt \
    && pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu

COPY api/ ./api/
COPY *.py ./

EXPOSE 8000

# Railway sets PORT at runtime
CMD ["sh", "-c", "uvicorn api.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
