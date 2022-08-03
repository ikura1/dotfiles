echo ".bashrc load"
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [[ $- =~ i ]]; then
    export PATH="${HOME}/local/bin:${PATH}"
    export PGDATA="/usr/local/var/postgres"
    export PYENV_ROOT="/usr/local/var/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    # export PATH="${HOME}/.pyenv/shims:${PATH}"
    # PEPENV
    export PIPENV_VENV_IN_PROJECT=true

fi
echo ".bashrc loaded"
