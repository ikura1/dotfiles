#!/bin/bash
set -eup pipefail

ln -fs ~/repos/dotfiles/.bashrc ~/.bashrc
ln -fs ~/repos/dotfiles/.zshrc ~/.zshrc
ln -ds ~/repos/dotfiles/.emacs.el ~/.emacs.el

# Sync Claude commands
mkdir -p ~/.claude/commands
cp ~/repos/dotfiles/.claude-commands/*.md ~/.claude/commands/


apt update -y

# Python package management with uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Upgrade pip for compatibility
pip install --upgrade pip

# node python uv
# emacs github
