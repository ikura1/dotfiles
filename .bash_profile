echo "bash_profile load"
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

export PATH="$HOME/.poetry/bin:$PATH"
