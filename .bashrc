if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [[ $- =~ i ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    export PGDATA="/usr/local/var/postgres"

    # pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    if command -v pyenv >/dev/null; then
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi

fi

# Volta (Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
if [ -d "$VOLTA_HOME" ]; then
    export PATH="$VOLTA_HOME/bin:$PATH"
fi

# pnpm
export PNPM_HOME="/home/ikura1/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Rust environment
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
