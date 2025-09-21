#!/bin/bash

# install-global-exo.sh
# Installs a global exo wrapper script for easy access from any directory
# This script follows best practices by being opt-in and reversible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing global exo wrapper...${NC}"

# Check if ~/.local/bin exists, create if not
if [[ ! -d "$HOME/.local/bin" ]]; then
    echo -e "${YELLOW}Creating ~/.local/bin directory...${NC}"
    mkdir -p "$HOME/.local/bin"
fi

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}Adding ~/.local/bin to PATH in ~/.zshrc...${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    echo -e "${YELLOW}Please run 'source ~/.zshrc' or restart your terminal for PATH changes to take effect.${NC}"
fi

# Create the global wrapper script
cat > "$HOME/.local/bin/exo" << 'EOF'
#!/bin/bash

# Global exo wrapper script - automatically finds and activates the exo virtual environment
# This allows 'exo' to work from any directory in any new terminal

# Function to find the exo project directory
find_exo_dir() {
    # Check if we're already in the exo directory
    if [[ -f ".venv/bin/activate" && -f "pyproject.toml" ]]; then
        echo "$(pwd)"
        return 0
    fi
    
    # Search in common locations
    local search_paths=(
        "/Users/uzayermasud/Developer/tools/exo"
        "$HOME/Developer/tools/exo"
        "$HOME/exo"
        "/opt/exo"
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -f "$path/.venv/bin/activate" && -f "$path/pyproject.toml" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    # If not found, return error
    echo "Error: Could not find exo installation directory" >&2
    echo "Please ensure exo is installed and the .venv directory exists" >&2
    echo "Run this script from the exo directory: ./install-global-exo.sh" >&2
    return 1
}

# Find the exo directory
EXO_DIR=$(find_exo_dir)
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Activate the virtual environment and run exo
source "$EXO_DIR/.venv/bin/activate"
exec exo "$@"
EOF

# Make the script executable
chmod +x "$HOME/.local/bin/exo"

echo -e "${GREEN}✅ Global exo wrapper installed successfully!${NC}"
echo -e "${GREEN}You can now run 'exo' from any directory.${NC}"
echo ""
echo -e "${YELLOW}For Apple Silicon Macs, consider running:${NC}"
echo -e "${YELLOW}  ./configure_mlx.sh${NC}"
echo -e "${YELLOW}This optimizes GPU memory allocation for better performance.${NC}"
echo ""
echo -e "${YELLOW}To uninstall the global wrapper, run:${NC}"
echo -e "${YELLOW}  rm ~/.local/bin/exo${NC}"
echo ""
echo -e "${YELLOW}To test, try:${NC}"
echo -e "${YELLOW}  exo --help${NC}"
