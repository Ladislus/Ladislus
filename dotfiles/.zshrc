export ZSH="$HOME/.oh-my-zsh"

# OMZ Config
ZSH_THEME="agnoster"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(git branch colored-man-pages sudo z zsh-syntax-highlighting fzf pass)

source "$ZSH/oh-my-zsh.sh"

# Enable extended wildcards/expension
setopt EXTENDED_GLOB

source "$HOME/.profile"
# Source custom scripts through aggregator
source "$SCRIPTS/ladislus.sh"

# Preferred editor for local and remote sessions
# if [[ -n "$SSH_CONNECTION" ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
export EDITOR='nvim'

# Direct GPG TTY to the current TTY (as sometimes it can't ask for passphrase)
export GPG_TTY="$(tty)"

# Aliases
alias ll='ls -Alhtr --color=auto'
alias activate='source venv/bin/activate'
alias update='_ladislus_package_update'

source <(fzf --zsh)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Remove system beep
xset -b