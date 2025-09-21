#!/usr/bin/env bash

# Check if uv is installed
if ! command -v uv &>/dev/null; then
    echo "uv is not installed. Installing uv..."
    
    # Try Homebrew first on macOS
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &>/dev/null; then
        echo "Installing uv via Homebrew..."
        brew install uv
    else
        echo "Installing uv via curl..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        source $HOME/.cargo/env
    fi
fi

echo "Using uv to create virtual environment and install exo..."

# Create virtual environment with uv (uses Python 3.12 by default if available)
uv venv

# Activate the virtual environment
source .venv/bin/activate

# Install the project in editable mode with uv
uv pip install -e .

# Add platform-specific dependencies based on system detection
if [[ "$OSTYPE" == "darwin"* ]] && [[ $(uname -m) == "arm64" ]]; then
    echo "Detected Apple Silicon macOS, installing MLX dependencies..."
    uv pip install -e ".[apple_silicon]"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Detected Windows, installing Windows dependencies..."
    uv pip install -e ".[windows]"
fi

# Check for NVIDIA GPU
if command -v nvidia-smi &>/dev/null; then
    echo "Detected NVIDIA GPU, installing NVIDIA dependencies..."
    uv pip install -e ".[nvidia-gpu]"
fi

# Check for AMD GPU (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v amd-smi &>/dev/null || command -v rocm-smi &>/dev/null; then
        echo "Detected AMD GPU, installing AMD dependencies..."
        uv pip install -e ".[amd-gpu,linux-amd]"
    fi
fi

echo "Installation complete!"
echo ""
echo "To run exo, you have several options:"
echo ""
echo "1. Activate the virtual environment first:"
echo "   source .venv/bin/activate"
echo "   exo"
echo ""
echo "2. Install global wrapper for easy access from anywhere:"
echo "   ./install-global-exo.sh"
echo ""
echo "3. Run directly with full path:"
echo "   .venv/bin/exo"
echo ""
echo "For Apple Silicon Macs, consider running ./configure_mlx.sh to optimize GPU memory allocation."
echo "See README.md for more performance tips."
