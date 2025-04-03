#!/bin/bash
set -e

# Check if we need to use sudo:
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
else
    SUDO=""
fi

# Parse command-line options
INSTALL_MINICONDA=false
EXPORT_CUDA=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --miniconda) INSTALL_MINICONDA=true ;;
        --cuda) EXPORT_CUDA=true ;;
        *) echo "Unknown option: $1" && exit 1 ;;
    esac
    shift
done

# 1. Update apt-get and install required packages
$SUDO apt-get update
$SUDO apt-get install -y zsh curl git

# 2. Install Oh-My-Zsh (non-interactive)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 3. Set Zsh as the default shell
chsh -s "$(command -v zsh)"

# 4. Copy your custom theme from the repo to Oh-My-Zsh's custom themes directory
mkdir -p "$HOME/.oh-my-zsh/custom/themes"
cp .oh-my-zsh/custom/themes/simple.zsh-theme "$HOME/.oh-my-zsh/custom/themes/"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 5. Copy your .zshrc from the repo to the home directory
cp .zshrc "$HOME/.zshrc"

# 6. Optionally install Miniconda
if [ "$INSTALL_MINICONDA" = true ]; then
    MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
    curl -O "https://repo.anaconda.com/miniconda/$MINICONDA_INSTALLER"
    bash "$MINICONDA_INSTALLER" -b -p "$HOME/.anaconda"
    rm "$MINICONDA_INSTALLER"
fi

# 7. Optionally detect the latest CUDA version and export its path
if [ "$EXPORT_CUDA" = true ]; then
    CUDA_PATH=""
    if [ -L "/usr/local/cuda" ]; then
        CUDA_PATH="/usr/local/cuda"
    elif compgen -G "/usr/local/cuda-*" > /dev/null; then
        CUDA_PATH=$(ls -d /usr/local/cuda-* | sort -V | tail -n 1)
    fi

    if [ -n "$CUDA_PATH" ]; then
        {
            echo ""
            echo "# Added by setup.sh: CUDA support"
            echo "export CUDA_PATH=\"$CUDA_PATH\""
            echo "export PATH=\"\$CUDA_PATH/bin:\$PATH\""
        } >> "$HOME/.zshrc"
        echo "CUDA detected and configured: $CUDA_PATH"
    else
        echo "CUDA option selected, but no CUDA installation was detected."
    fi
fi

echo "Setup complete. Please restart your terminal."
