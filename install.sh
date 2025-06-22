#!/bin/bash
set -eup pipefail

ln -fs ~/repos/dotfiles/.bashrc ~/.bashrc
ln -fs ~/repos/dotfiles/.zshrc ~/.zshrc
ln -ds ~/repos/dotfiles/.emacs.el ~/.emacs.el


apt update -y

pip install --upgrade pip

# node python
# emacs github
