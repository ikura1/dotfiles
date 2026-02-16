#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

ln -fs "${DOTFILES_DIR}/.bashrc" ~/.bashrc
ln -fs "${DOTFILES_DIR}/.zshrc" ~/.zshrc
ln -fs "${DOTFILES_DIR}/.emacs.el" ~/.emacs.el

# Install Claude dotfiles (symlinks for agents/, commands/, rules/)
bash "$(dirname "$0")/scripts/install-claude.sh"


apt update -y

# Python package management with uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Upgrade pip for compatibility
pip install --upgrade pip

# node python uv
# emacs github
