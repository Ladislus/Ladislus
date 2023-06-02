export ZSH="$HOME/.oh-my-zsh"

# OMZ Config
ZSH_THEME="agnoster"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(git branch colored-man-pages sudo z zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# Enable extended wildcards/expension
setopt EXTENDED_GLOB

# Source custom scripts through aggregator
source "$SCRIPTS/ladislus.sh"

# Preferred editor for local and remote sessions
if [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR='code'
else
  export EDITOR='vim'
fi

# Git config
git config --global user.email "walcak.ladislas@gmail.com"
git config --global user.name "Ladislus"
# git config --global user.signingkey ?????
git config --global init.defaultBranch master
git config --global alias.graph 'log --oneline --decorate --all --graph --stat --pretty="tformat:%C(bold yellow)Commit : %h %n%C(yellow)Author : %an (%ae)%n%C(yellow)Date : %ar%n%n%s"'
git config --global alias.hard 'reset --hard'
git config --global alias.cm 'commit -m'
git config --global alias.cms 'commit -S -m'
git config --global alias.amend 'commit --amend'
git config --global alias.patch 'add --patch'
git config --global alias.cr 'clone --recursive'
git config --global alias.su 'submodule update --init --recursive'

# Direct GPG TTY to the current TTY (as sometimes it can't ask for passphrase)
export GPG_TTY="$(tty)"

# Aliases
alias ls='ls -Alhtr --color=auto'
alias top='htop -t'
alias activate='source venv/bin/activate'
alias update='_ladislus_package_update'

# Remove system beep
xset -b
