# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing shell and editor configuration files. The repository manages configuration for multiple shells (bash, zsh, xonsh) and Emacs editor.

## Installation and Setup

### Installing Dotfiles
- Use `make install` or `./install.sh` to install dotfiles
- The install script creates symlinks from home directory to the dotfiles in this repo
- Requires sudo access for package installation (apt update, pip install)

### Dependencies
- Python 3 with pip
- xonsh shell (installed via pip during setup)
- pyenv for Python version management
- Volta for Node.js management
- pnpm for package management
- Rust/Cargo environment

## Configuration Files Structure

### Shell Configurations
- `.bashrc` - Bash configuration with PATH setup and tool initialization
- `.zshrc` - Zsh configuration with minimal setup, aliases, and prompt customization
- `.xonshrc` - Xonsh shell configuration with Python-style settings and prompt

### Editor Configuration
- `.emacs.el` - Emacs configuration with custom key bindings, visual settings, and whitespace highlighting

### Environment Setup
- `.python-version` - Contains "system" indicating use of system Python
- `.gitignore` - Ignores VS Code settings and Emacs temporary files

## Key Features

### Shell Environment
- All shells configured with pyenv integration for Python version management
- Volta integration for Node.js/npm management
- Rust/Cargo environment loading
- Custom aliases and prompts for each shell
- Directory auto-completion and navigation shortcuts

### Development Tools Integration
- pyenv for Python version management across all shells
- pnpm configured for package management
- Cargo/Rust environment integration
- Local bin directory in PATH for user-installed tools

### Editor Setup
- Emacs configured for terminal use (`emacs -nw` alias)
- Custom key bindings (C-h for backspace, C-/ for undo)
- Visual enhancements (line highlighting, bracket matching, custom colors)
- Whitespace and full-width space highlighting for better code formatting

## Shell-Specific Notes

### Xonsh Configuration Highlights
- Interactive completions with keypress updates
- Auto-completion for directory navigation
- Comprehensive error reporting and logging
- Custom prompt with color coding for user/host/directory

### Zsh Configuration Highlights
- Minimal setup focused on essential features
- Auto-completion with case-insensitive matching
- Directory navigation with auto_cd and pushd management
- Custom prompt with color-coded status indication