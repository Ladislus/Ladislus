export ZSH="/home/ladislus/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(git z branch cargo rustup colored-man-pages cp docker docker-compose virtualenv)
source $ZSH/oh-my-zsh.sh
alias ls='ls -Alhtr --color=auto'
