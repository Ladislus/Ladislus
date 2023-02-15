export ZSH="/home/ladislus/.oh-my-zsh"

# OMZ Config
ZSH_THEME="agnoster"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(git branch colorize colored-man-pages sudo z zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='code'
else
  export EDITOR='vim'
fi

# Git config
git config --global user.email "walcak.ladislas@gmail.com"
git config --global user.name "Ladislus"
git config --global user.signingkey ?????
git config --global credential.helper store
git config --global init.defaultBranch master
git config --global alias.graph 'log --oneline --decorate --all --graph --stat --pretty="tformat:%C(bold yellow)Commit : %h %n%C(yellow)Author : %an (%ae)%n%C(yellow)Date : %ar%n%n%s"'
git config --global alias.hard 'reset --hard'
git config --global alias.cm 'commit -m'
git config --global alias.cms 'commit -S -m'
git config --global alias.amend 'commit --amend'

# Hack to allow WSL to prompt for GPG Passphrase
# export GPG_TTY=$(tty)

# Aliases
alias ls='ls -Alhtr --color=auto'
alias top='htop -t'
alias valgrind_full='valgrind --leak-check=full --track-origins=yes --show-error-list=yes'
alias activate='source venv/bin/activate'

function update() {
  echo '	############'
  echo '	# PACKAGES #'
  echo '	############\n'
  sudo pacman -Syu
  pamac update


  echo '\n	##########'
  echo '	# PYTHON #'
  echo '	##########\n'
  pip install --upgrade pip
  pip3 list -o | cut -f1 -d' ' | tr " " "\n" | awk '{if(NR>=3)print}' | cut -d' ' -f1 | xargs -n1 pip3 install -U 2> /dev/null


  echo '\n	########'
  echo '	# RUST #'
  echo '	########\n'
  rustup update


  echo '\n	#############'
  echo '	# Oh-My-Zsh #'
  echo '	#############\n'
  omz update
}

# Remove system beep
xset -b
