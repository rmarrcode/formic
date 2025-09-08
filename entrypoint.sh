#!/bin/bash

# Parse command line arguments
BOOTSTRAP_MODE=false
INITIAL_PEERS=""
MODEL_NAME="meta-llama/Meta-Llama-3.1-405B-Instruct"
NUM_BLOCKS=5
DEVICE="cuda"
HUGGING_FACE_HUB_TOKEN=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --bootstrap)
            BOOTSTRAP_MODE=true
            shift
            ;;
        --initial-peers|--initial_peers)
            INITIAL_PEERS="$2"
            shift 2
            ;;
        --model)
            MODEL_NAME="$2"
            shift 2
            ;;
        --num-blocks)
            NUM_BLOCKS="$2"
            shift 2
            ;;
        --device)
            DEVICE="$2"
            shift 2
            ;;
        --hf-token)
            HUGGING_FACE_HUB_TOKEN="$2"
            shift 2
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done



# Check if HUGGING_FACE_HUB_TOKEN is provided
if [ -z "$HUGGING_FACE_HUB_TOKEN" ]; then
    echo "Error: --hf-token argument is required"
    echo "Usage: docker run your_image --hf-token YOUR_TOKEN [--bootstrap] [--initial-peers PEER_ADDRESS] [--model MODEL_NAME] [--num-blocks N] [--device DEVICE]"
    exit 1
fi

echo "Setting up Hugging Face authentication..."
echo "Token: ${HUGGING_FACE_HUB_TOKEN:0:10}..." # Show first 10 chars for verification

# Set the token
export HUGGING_FACE_HUB_TOKEN

# Check if Petals is installed, install if not
echo "Checking if Petals is installed..."
if ! python -c "import petals" 2>/dev/null; then
    echo "Petals not found. Installing from GitHub..."
    pip install torch==2.2.2 torchvision==0.17.2 torchaudio==2.2.2 --index-url https://download.pytorch.org/whl/cu121
    pip install git+https://github.com/bigscience-workshop/petals
else
    echo "Petals is already installed."
fi

# Test CUDA and bitsandbytes availability
# echo "Testing CUDA and bitsandbytes availability..."
# if ! python -c "
# import torch
# print('PyTorch CUDA available:', torch.cuda.is_available())
# if torch.cuda.is_available():
#     print('PyTorch CUDA version:', torch.version.cuda)
#     print('GPU count:', torch.cuda.device_count())

# # Test bitsandbytes specifically
# try:
#     import bitsandbytes as bnb
#     print('bitsandbytes import: SUCCESS')
#     print('bitsandbytes version:', bnb.__version__)
# except Exception as e:
#     print('bitsandbytes import: FAILED')
#     print('Error:', str(e))
#     exit(1)
# " 2>/dev/null; then
#     echo "CUDA/bitsandbytes test failed!"
#     echo "This usually means:"
#     echo "1. CUDA version mismatch between PyTorch and bitsandbytes"
#     echo "2. Missing CUDA libraries in LD_LIBRARY_PATH"
#     echo "3. bitsandbytes compiled for different CUDA version"
#     echo ""
#     echo "To fix this, try:"
#     echo "1. Reinstall bitsandbytes: pip uninstall bitsandbytes && pip install bitsandbytes"
#     echo "2. Check CUDA version: nvidia-smi"
#     echo "3. Set LD_LIBRARY_PATH: export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH"
#     exit 1
# else
#     echo "CUDA and bitsandbytes test passed!"
# fi

# Login to Hugging Face (optional, but helps with authentication)
echo "Logging into Hugging Face..."
huggingface-cli login --token $HUGGING_FACE_HUB_TOKEN

# Print network information
echo "=== Network Information ==="
echo "Container IP addresses:"
ip addr show | grep -E "inet [0-9]" | grep -v "127.0.0.1" | awk '{print "  " $2}' | cut -d'/' -f1
echo "Hostname: $(hostname)"
echo "=========================="

if [ "$BOOTSTRAP_MODE" = true ]; then
    echo "Starting Petals DHT bootstrap node..."
    echo "To connect other peers, use the --initial_peers address shown below"
    
    # Run the DHT bootstrap
    python -m petals.cli.run_dht --host_maddrs /ip4/0.0.0.0/tcp/1111 /ip6/::/tcp/1111
else
    # Server mode
    if [ -z "$INITIAL_PEERS" ]; then
        echo "Error: --initial-peers is required for server mode"
        echo "Usage: docker run your_image --hf-token YOUR_TOKEN --initial-peers /ip4/.../p2p/... [--model MODEL_NAME] [--num-blocks N] [--device DEVICE]"
        exit 1
    fi
    
    echo "Starting Petals server..."
    echo "Model: $MODEL_NAME"
    echo "Initial peers: $INITIAL_PEERS"
    echo "Number of blocks: $NUM_BLOCKS"
    echo "Device: $DEVICE"
    
    
    # Run the server
    python -m petals.cli.run_server "$MODEL_NAME" \
        --initial_peers "$INITIAL_PEERS" \
        --num_blocks "$NUM_BLOCKS" \
        --device "$DEVICE"
fi


