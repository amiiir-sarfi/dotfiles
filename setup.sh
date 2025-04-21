#!/bin/bash
set -e

# Check if we need to use sudo:
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
else
    SUDO=""
fi

# 1. Update apt-get and install required packages
$SUDO apt-get update
$SUDO apt-get install -y zsh curl git

# 2. Install Oh-My-Zsh (non-interactive)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 3. Set Zsh as the default shell for the target user
$SUDO chsh -s "$(command -v zsh)" "$USER"

# 4. Copy your custom theme from the repo to Oh-My-Zsh's custom themes directory
mkdir -p "$HOME/.oh-my-zsh/custom/themes"
if [ -f ".oh-my-zsh/custom/themes/simple.zsh-theme" ]; then
    cp .oh-my-zsh/custom/themes/simple.zsh-theme "$HOME/.oh-my-zsh/custom/themes/"
else
    echo "Warning: simple.zsh-theme not found in .oh-my-zsh/custom/themes/"
fi

# 5. Install plugins if they are not already installed
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 6. Backup any existing .zshrc and copy your .zshrc from the repo to the home directory
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
    echo "Existing .zshrc backed up to .zshrc.backup"
fi
cp .zshrc "$HOME/.zshrc"

echo "Setup complete. Please restart your terminal."
