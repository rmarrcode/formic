#!/bin/bash
echo "Testing CUDA..."
python -c "import torch; print('CUDA:', torch.cuda.is_available())"
echo "Testing bitsandbytes..."
python -c "import bitsandbytes; print('bitsandbytes: OK')"
echo "GPU Info:"
nvidia-smi --query-gpu=name,memory.total --format=csv