echo ".bashrc load"
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [[ $- =~ i ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    export PGDATA="/usr/local/var/postgres"

    # pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    # PEPENV
    export PIPENV_VENV_IN_PROJECT=true

    # poetry
    export POETRY_HOME="~/.local/share/pypoetry/venv/bin/poetry"

    # rye
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    source "$HOME/.rye/env"

    # xonsh

fi
echo ".bashrc loaded"
