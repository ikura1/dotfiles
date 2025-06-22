# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing shell and editor configuration files. The repository manages configuration for multiple shells (bash, zsh) and Emacs editor.

## Installation and Setup

### Installing Dotfiles
- Use `make install` or `./install.sh` to install dotfiles
- The install script creates symlinks from home directory to the dotfiles in this repo
- Requires sudo access for package installation (apt update, pip install)

### Dependencies
- Python 3 with pip
- pyenv for Python version management
- Volta for Node.js management
- pnpm for package management
- Rust/Cargo environment

## Configuration Files Structure

### Shell Configurations
- `.bashrc` - Bash configuration with PATH setup and tool initialization
- `.zshrc` - Enhanced Zsh configuration with comprehensive aliases, functions, and prompt customization

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

### Zsh Configuration Highlights
- Enhanced history management (10,000 entries, deduplication)
- Comprehensive alias collection for Git, development, and system operations
- Advanced prompt with Git status and Python environment display
- Useful functions (mkcd, extract, ff for file finding)
- Improved key bindings and auto-completion
- Plugin support for syntax highlighting and auto-suggestions
- Performance optimizations with lazy loading