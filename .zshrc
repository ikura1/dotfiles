# Enhanced zshrc configuration

# ===========================
# Core ZSH Configuration
# ===========================

# Initialize completion system
autoload -U compinit; compinit

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_MINUS
setopt CDABLE_VARS

# Completion settings
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_LIST
setopt LIST_PACKED
setopt LIST_TYPES
setopt MENU_COMPLETE

# Other useful options
setopt IGNOREEOF
setopt CORRECT
setopt CORRECT_ALL
setopt PROMPT_SUBST
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB
setopt NUMERIC_GLOB_SORT

# Locale
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# Colors
autoload -Uz colors
colors

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache

# ===========================
# Aliases and Functions
# ===========================

# Enhanced ls aliases
alias ls='ls --color=auto'
alias l='ls -ltr --color=auto'
alias la='ls -la --color=auto'
alias ll='ls -alF --color=auto'
alias lt='ls -ltr --color=auto'
alias lh='ls -lah --color=auto'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gst='git status'
alias gb='git branch'
alias gba='git branch -a'

# Utility aliases
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias h='history'
alias hg='history | grep'
alias c='clear'
alias q='exit'
alias reload='source ~/.zshrc'
alias zshconfig='emacs -nw ~/.zshrc'

# Development aliases
alias py='python3'
alias pip='pip3'
alias v='vim'
alias e='emacs -nw'
alias mk='make'
alias dc='docker-compose'
alias k='kubectl'

# UV Python package manager aliases
alias uvi='uv init'
alias uvr='uv run'
alias uva='uv add'
alias uvs='uv sync'
alias uvl='uv lock'
alias uvt='uv tool'
alias uvp='uv python'
alias uvc='uv cache'

# Network and system
alias ports='netstat -tulanp'
alias ping='ping -c 5'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Functions
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find files by name
ff() {
    find . -name "*$1*" 2>/dev/null
}

# UV Python project functions
uvnew() {
    if [ -z "$1" ]; then
        echo "Usage: uvnew <project_name>"
        return 1
    fi
    uv init "$1" && cd "$1"
}

# UV virtual environment activation
uvenv() {
    if [ -f "pyproject.toml" ]; then
        source .venv/bin/activate
    else
        echo "No pyproject.toml found. Run 'uv init' first."
    fi
}

# UV dependency management helper
uvdev() {
    uv add --dev "$@"
}

# ===========================
# Enhanced Prompt
# ===========================

# Git prompt function
git_prompt_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
        local git_status=""
        
        # Check for uncommitted changes
        if ! git diff --quiet 2>/dev/null; then
            git_status="%{$fg[red]%}✗%{$reset_color%}"
        elif ! git diff --cached --quiet 2>/dev/null; then
            git_status="%{$fg[yellow]%}✓%{$reset_color%}"
        else
            git_status="%{$fg[green]%}✓%{$reset_color%}"
        fi
        
        echo " %{$fg[cyan]%}(%{$fg[yellow]%}$branch%{$fg[cyan]%}$git_status%{$fg[cyan]%})"
    fi
}

# Python virtual environment prompt
python_prompt_info() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo " %{$fg[green]%}[$(basename $VIRTUAL_ENV)]%{$reset_color%}"
    fi
}

# Enhanced prompt with git and python info
PROMPT='%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m%{$reset_color%} %{$fg[yellow]%}%~%{$reset_color%}$(git_prompt_info)$(python_prompt_info)
%(?.%{$fg[green]%}➜%{$reset_color%}.%{$fg[red]%}➜%{$reset_color%}) '
RPROMPT='%{$fg[cyan]%}[%D{%H:%M:%S}]%{$reset_color%}'

# ===========================
# Development Environment
# ===========================

# Local binaries
export PATH="${HOME}/.local/bin:${PATH}"

# Database
export PGDATA="/usr/local/var/postgres"

# Python environment
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv >/dev/null; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# UV - Python package and project manager
if [ -f "$HOME/.cargo/bin/uv" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
    export UV_CACHE_DIR="$HOME/.cache/uv"
    export UV_CONFIG_FILE="$HOME/.config/uv/uv.toml"
fi

# Node.js environment (Volta)
export VOLTA_HOME="$HOME/.volta"
if [ -d "$VOLTA_HOME" ]; then
    export PATH="$VOLTA_HOME/bin:$PATH"
fi

# Package managers
# pnpm
export PNPM_HOME="/home/ikura1/.local/share/pnpm"
if [ -d "$PNPM_HOME" ]; then
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi

# Rust environment
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# ===========================
# Key Bindings
# ===========================

# Emacs-style key bindings
bindkey -e

# History search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Better word navigation
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Delete key
bindkey '^[[3~' delete-char

# Home/End keys
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# ===========================
# Performance Optimizations
# ===========================

# Lazy load functions for better startup time
lazy_load() {
    local command=$1
    shift
    eval "$command() { unfunction $command; $* && $command \"\$@\"; }"
}

# Auto-suggestions (if available)
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
fi

# Syntax highlighting (if available)
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
