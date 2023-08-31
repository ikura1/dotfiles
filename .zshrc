# 人類最低限zshrc
autoload -U compinit; compinit
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt histignorealldups
setopt always_last_prompt
setopt complete_in_word
setopt IGNOREEOF
export LANG=ja_JP.UTF-8
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
autoload -Uz colors
colors

alias l='ls -ltr --color=auto'
alias ls='ls --color=auto'
alias la='ls -la --color=auto'
PROMPT="%(?.%{${fg[red]}%}.%{${fg[red]}%})%n${reset_color}@${fg[blue]}%m${reset_color} %~ %# "

# local
export PATH="${HOME}/.local/bin:${PATH}"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# poetry
export POETRY_HOME="~/.local/share/pypoetry/venv/bin/poetry"

# PEPENV
export PIPENV_VENV_IN_PROJECT=true

# xonsh起動
alias x='xonsh'
# x
