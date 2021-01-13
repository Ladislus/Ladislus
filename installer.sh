#####################
#       Main        #
#####################

# Clean des applications de bases non voulues
sudo pacman -Rns kate firefox konversation manjaro-hello thunderbird cantata

base='base-devel htop grep sudo pacman which zsh gparted ark spectacle kcalc wget tree'
consoles='konsole yakuake'
aur='pamac'
main='vlc okular gwenview dolphin discord bitwarden youtube-dl qbittorrent'
dev='git code make cmake doxygen docker mysql okteta'
jeu='steam-manjaro lutris'

lang_c='gcc clang valgrind'
lang_java='jre-openjdk jdk-openjdk maven'
lang_python='python2 python2-pip python3 python-pip'
languages="kotlin go lua rustup php $lang_c $lang_java $lang_python"

# Installation des paquets
sudo pacman -Syu $base $consoles $aur $main $dev $jeu $languages

# Configuration de pip
pip3 install --upgrade pip
pip install --upgrade pip
# Packages python
pip install virtualenv lyrics-in-terminal

# Configuration de rust
rustup toolchain install stable
rustup default stable
rustup -V

#####################
#        AUR        #
#####################

internet='google-chrome mailspring'
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
