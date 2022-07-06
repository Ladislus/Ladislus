#####################
#       Main        #
#####################

# Clean des applications de bases non voulues
sudo pacman -Rns kate firefox konversation manjaro-hello thunderbird cantata

base='base-devel htop grep sudo pacman which zsh gparted ark spectacle wget tree'
consoles='konsole yakuake'
aur='pamac'
main='vlc okular gwenview dolphin discord bitwarden youtube-dl qbittorrent'
dev='git code make cmake doxygen docker docker-compose'

lang_c='gcc clang valgrind'
lang_python='python3 python-pip'
languages="kotlin rustup $lang_c $lang_python"

# Installation des paquets
sudo pacman -Syu $base $consoles $aur $main $dev $languages

# Configuration de pip
pip3 install --upgrade pip
# Packages python
pip install virtualenv lyrics-in-terminal

# Configuration de rust
rustup toolchain install stable
rustup default stable
rustup -V

#####################
#        AUR        #
#####################

internet='google-chrome'
dev='jetbrains-toolbox'
music='spotify spicetify-cli'
jeu='ankama-launcher minecraft-launcher'
dependencies='go-chroma' #Dependance pour ccat (plugin zsh)

pamac build $internet $dev $music $jeu $dependencies

#####################
#        ZSH        #
#####################

sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ZSH par défaut
chsh -s $(which zsh)
sudo chsh -s $(which zsh)
