SCRIPT_LOCATION=$(dirname -- ${BASH_SOURCE[0]})
echo "Install script location \"$SCRIPT_LOCATION\""

#####################
#     PACKAGES      #
#####################

# Clean KDE default unwanted application
sudo pacman -Rns kate firefox manjaro-hello

# Install required packages
# PACKAGES_SYSTEM='base-devel git htop grep sudo vim which wget curl tree openssh zip unzip sddm'
# PACKAGES_INSTALLER='pacman pamac'
# PACKAGES_CONSOLE='yakuake zsh'
# PACKAGES_UTILS='gparted ark spectacle vlc okular gwenview dolphin'
# PACKAGES_PLUS='discord yt-dlp'
# PACKAGES_EDITOR='code'
# PACKAGES_DOCKER='docker docker-compose'
# PACKAGES_C='gcc clang valgrind make cmake doxygen'
# PACKAGES_PYTHON='python3 python-pip'
# PACKAGES_JAVA='jdk8-openjdk jre8-openjdk jdk11-openjdk jre11-openjdk kotlin'
# PACKAGES_RUST="rustup"

# PACKAGES_ALL="$PACKAGES_SYSTEM $PACKAGES_INSTALLER $PACKAGES_CONSOLE $PACKAGES_UTILS $PACKAGES_PLUS $PACKAGES_EDITOR $PACKAGES_DOCKER $PACKAGES_C $PACKAGES_PYTHON $PACKAGES_JAVA $PACKAGES_RUST"

# echo "All packages: $PACKAGES_ALL"
sudo pacman -Syu --needed base-devel git htop grep sudo vim which wget curl tree openssh zip unzip sddm pacman pamac yakuake zsh gparted ark spectacle vlc okular gwenview dolphin discord yt-dlp code docker docker-compose gcc clang valgrind make cmake doxygen python3 python-pip jdk8-openjdk jre8-openjdk jdk11-openjdk jre11-openjdk kotlin rustup

#####################
#        AUR        #
#####################

# Enabling AUR support on pamac
sudo sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

# Add tor-browser GPG key for signature check (as it's not in the default key servers)
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org

# PACKAGES_INTERNET='google-chrome tor-browser'
# PACKAGES_MUSIC='spotify spicetify-cli'
# PACKAGES_DEPENDENCIES='go-chroma' #Dependency for ccat (OhMyZsh plugin)

# PACKAGES_ALL="$PACKAGES_INTERNET $PACKAGES_MUSIC $PACKAGES_DEPENDENCIES"

# echo "AUR Packages: $PACKAGES_ALL"
# pamac install $PACKAGES_ALL
pamac install google-chrome tor-browser spotify spicetify-cli go-chroma

#####################
#        ZSH        #
#####################

# Install OhMyZsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set ZSH as default
chsh -s $(which zsh)
sudo chsh -s $(which zsh)

# Set config and load it
cat $SCRIPT_LOCATION/.zshrc > ~/.zshrc
source ~/.zshrc

# Install Zsh-syntax-highlight plugin
git -C $ZSH/plugins/ clone https://github.com/zsh-users/zsh-syntax-highlighting.git

#####################
#       KEYS        #
#####################

ssh-keygen -t rsa -b 4096

#####################
#      PYTHON       #
#####################

# Configure pip & installed packages
pip3 install --upgrade pip
pip install virtualenv

#####################
#       RUST        #
#####################

# Install Rust stable toolchain
rustup toolchain install stable
rustup default stable
rustup -V

#####################
#     SPICETIFY     #
#####################

# Set permissions to change spotify look
sudo chmod a+wr /opt/spotify -R

# Download themes
git -C ~/.config/spicetify/Themes/ clone https://github.com/morpheusthewhite/spicetify-themes
mv ~/.config/spicetify/Themes/spicetify-themes/* ~/.config/spicetify/Themes/
rm -rf ~/.config/spicetify/Themes/spicetify-themes

# Set Spotify theme
spicetify backup apply
spicetify config current_theme BurntSienna
spicetify apply

#####################
#     RUSTYVIBES    #
#####################

cargo install rustyvibes
unzip -d ~ $SCRIPT_LOCATION/soundpacks.zip

echo '~/.cargo/bin/rustyvibes ~/.rustyvibes-soundpacks/cherrymx-black-pbt &' >> ~/.xprofile

#####################
#      CONFIGS      #
#####################

cp -r $SCRIPT_LOCATION/.config/ ~
cp -r $SCRIPT_LOCATION/.local/ ~
cp -r $SCRIPT_LOCATION/.icons/ ~
sudo cp -r $SCRIPT_LOCATION/usr/ /