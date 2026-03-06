# syntax=docker/dockerfile:1
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv python3-dev \
    build-essential cmake pkg-config \
    git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace/hivemind
COPY . /workspace/hivemind

RUN python3 -m pip install --upgrade pip setuptools wheel
# Install the CUDA-enabled PyTorch build matching the CUDA 12.1 runtime in this image.
RUN python3 -m pip install torch --index-url https://download.pytorch.org/whl/cu121

# Install core deps, hivemind in editable mode, then example deps and pinned wheels.
RUN python3 -m pip install -r requirements.txt \
    && python3 -m pip install -e . \
    && python3 -m pip install -r examples/albert/requirements.txt \
    && python3 -m pip install --no-deps \
        'protobuf>=5.29.0,<6.0.0' \
        'uvloop>=0.19.0' \
        'msgpack>=1.0.8' \
        'base58>=2.1.1' \
        'py-multihash>=0.2.3' \
        'py-cid>=0.3.0' \
        'varint>=1.0.2'

ENV HF_HOME=/workspace/.cache/huggingface \
    TRANSFORMERS_CACHE=/workspace/.cache/huggingface/transformers \
    DATASETS_CACHE=/workspace/.cache/huggingface/datasets

VOLUME ["/workspace/hivemind/data", "/workspace/hivemind/logs", "/workspace/hivemind/outputs"]

ENTRYPOINT ["python3", "examples/albert/run_trainer.py"]