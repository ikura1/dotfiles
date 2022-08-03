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
alias l='ls -ltrG'
alias ls='ls -G'
alias la='ls -laG'
PROMPT="%(?.%{${fg[red]}%}.%{${fg[red]}%})%n${reset_color}@${fg[blue]}%m${reset_color} %~ %# "

export PATH="$HOME/local/bin:$PATH"
export PATH="$HOME/.yearn/bin:$PATH"

# emacs
export VISUAL='/usr/local/bin/emacs'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# PEPENV
export PIPENV_VENV_IN_PROJECT=true

# xonsh起動
alias x='xonsh'
x
B
