#####################
#    ENVIRONMENT    #
#####################

# Assert that $HOME is set
if [[ -z "$HOME" ]]; then
    >&2 echo "\$HOME environment variable is empty"
    return 1
fi

# Set environment variable
export CATPPUCCIN="$HOME/.catppuccin"
export SPICETIFY="$HOME/.spicetify"
export GIT="$HOME/Git"
export DOTFILES="$GIT/Ladislus/dotfiles"
export SCRIPTS="$DOTFILES/scripts"
export WALLPAPERS="$DOTFILES/wallpapers"
export SOUNDPACKS="$DOTFILES/soundpacks"

# Create required folders if they don't already exist
mkdir -p "$GIT" "$CATPPUCCIN"

# Check that dotfile folder exists
if [[ ! -d "$DOTFILES" ]]; then
    echo "Dotfiles missing, cloning it"
    git -C "$GIT" clone "https://github.com/Ladislus/Ladislus.git"

    # If cloning the repository didn't fix the missing folder, this means the 'dotfiles' subfolder in the git repository was probably renamed
    if [[ ! -d "$DOTFILES" ]]; then
        >&2 echo "Cloning dotfiles repository didn't fix it, something is wrong, aborting"
        return 1
    fi
fi

# Source script as they contains usefull functions
source "$SCRIPTS/ladislus.sh" || return 1

#####################
#     PACKAGES      #
#####################

# Enable colored output for pacman
sudo sed -Ei '/Color/s/^#//' /etc/pacman.conf

# Enabling AUR support on pamac
sudo sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

# Clean i3 default unwanted application
TOREMOVE=(i3exit i3lock mousepad conky kvantum kvantum-manjaro xautolock i3status-manjaro moc manjaro-i3-settings palemoon-bin epdfview xterm urxvt-perls manjaro-ranger-settings ranger dmenu-manjaro morc_menu bmenu pcmanfm polkit-gnome)
_ladislus_package_remove "${TOREMOVE[@]}"

unset TOREMOVE

# Install required packages
PACKAGES+=(base-devel i3-wm git xss-lock htop numlockx bashtop i3-scrot grep sudo which wget curl tree ncdu openssh zip unzip tar networkmanager blueberry xarchiver clipit nitrogen xfce4-power-manager)
PACKAGES+=(lightdm lightdm-slick-greeter qt5ct gtk-engine-murrine lightly-qt)
PACKAGES+=(pacman pamac)
PACKAGES+=(zsh kitty vim)
PACKAGES+=(polybar rofi dunst picom)
PACKAGES+=(vlc thunar)
PACKAGES+=(discord betterdiscordctl google-chrome tor-browser spotify spicetify-cli)
PACKAGES+=(code)
PACKAGES+=(docker docker-compose)
PACKAGES+=(gcc clang valgrind make cmake doxygen)
PACKAGES+=(python3 python-pip)
PACKAGES+=(jdk8-openjdk jre8-openjdk jdk11-openjdk jre11-openjdk kotlin)
PACKAGES+=(rustup)

pamac install --no-confirm "${PACKAGES[@]}"

unset PACKAGES

# Remove packages that are not required anymore
pamac remove -o --no-confirm

#####################
#        ZSH        #
#####################

# If not already installed, install OhMyZsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    # Install OhMyZsh
    sh -c "$(wget -O- "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh")"

    # Set ZSH as default
    chsh -s "$(which zsh)"
    sudo chsh -s "$(which zsh)"

    # Set config and load it
    cat "$DOTFILES/.zshrc" > "$HOME/.zshrc"
    source "$HOME/.zshrc"

    # Install Zsh-syntax-highlight plugin
    git -C "$ZSH/plugins" clone "https://github.com/zsh-users/zsh-syntax-highlighting.git"
fi

#####################
#       KEYS        #
#####################

# Generate SSH key
ssh-keygen -t rsa -b 4096

# Generate GPG key
gpg --full-generate-key
# TODO: Find way to automatically change in .zshrc
# POST: Set Signing key in .zshrc
# POST: Add keys to Github
# POST: "gpg --list-secret-keys --keyid-format long" To list GPG keys
# POST: "gpg --export --armor KEYID" To get the ASCII version of the public key (where KEYID is "sec" section, without the algorithm)

#####################
#      PYTHON       #
#####################

# Update pip
pip3 install --upgrade pip
# Install system-wide packages
pip install virtualenv

#####################
#       RUST        #
#####################

# Install Rust stable toolchain
rustup toolchain install stable
rustup default stable
rustup -V

#####################
#       CODE        #
#####################

# Install Code extensions via extension IDs
EXTENSIONS=(Catppuccin.catppuccin-vsc ms-python.python PKief.material-icon-theme rust-lang.rust-analyzer)
for _X in $EXTENSIONS; do
    code --install-extension "$_X"
done

unset EXTENSIONS

# Copy custom config files
cp -r "$DOTFILES/.config/Code - OSS" $HOME/.config

#####################
#   POWER MANAGER   #
#####################

# Copy custom config
cp -r $DOTFILES/.config/xfce4 $HOME/.config

#####################
#      SYSTEMCTL    #
#####################

# Enable bluetooth & docker service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now docker.service

#####################
#         I3        #
#####################

# TODO: Configure

# Copy i3 custom config file
cp -r $DOTFILES/.config/i3 $HOME/.config
cp $DOTFILES/.profile $HOME

# Uprade from alsa -> pulseaudio
pulse_install

#####################
#       ICONS       #
#####################

# Copy custom icons
cp -r "$DOTFILES/.icons" "$HOME"
# Remove icons folder in .local to prevent default icons
rm -rf "$HOME/.local/share/icons"

#####################
#       FONTS       #
#####################

# Copy custom fonts
cp -r "$DOTFILES/.fonts" "$HOME"
# Reload font cache
fc-cache -fv

#####################
#      QT THEME     #
#####################

QT_THEMES="$HOME/.config/qt5ct/colors/"
QT_GIT="$CATPPUCCIN/qt5ct"

# Clone Catppuccin theme for Rofi
if [[ ! -d "$QT_GIT" ]]; then
    git -C "$CATPPUCCIN" clone "https://github.com/Catppuccin/qt5ct.git"
fi

# Create required folders
mkdir -p "$QT_THEMES"

# Create symlink for Catppuccin theme inside qt5ct themes
for _X in $QT_GIT/themes/*.conf; do
    ln -s -T "$_X" "$QT_THEMES/$(basename "$_X")"
done

cp $DOTFILES/.config/qt5ct/qt5ct.conf $HOME/.config/qt5ct

unset QT_THEMES
unset QT_GIT

#####################
#     GTK THEME     #
#####################

GTK_THEMES="$HOME/.themes"
GTK_GIT="$CATPPUCCIN/gtk"

# Create required folders
mkdir -p "$GTK_THEMES"

# Clone Catppuccin theme for Rofi
if [[ ! -d "$GTK_GIT" ]]; then
    git -C "$CATPPUCCIN" clone "https://github.com/Catppuccin/gtk.git"
fi

# Prepare python environment
cd $GTK_GIT
virtualenv -p python3 venv
source venv/bin/activate
pip install -r requirements.txt

# Generate frappe pink variants
python install.py frappe -a flamingo --tweaks rimless -d "$GTK_THEMES"

# deactivate python env
deactivate
rm -rf ./venv

# Copy configs
cp -r $DOTFILES/.config/gtk-{2,3}.0 $HOME/.config
cp $DOTFILES/.config/.gtkrc-2.0.mine $HOME/.config

# Source custom gtk config inside .gtkrc file (only for GTK2)
echo "include \"$HOME/.config/.gtkrc-2.0.mine\"" > "$HOME/.gtkrc-2.0"

unset GTK_THEMES
unset GTK_GIT

#####################
#   LIGHTDM THEME   #
#####################

# Copy cursor, icons and theme to /usr (can't create symlinks)
sudo cp -r $HOME/.icons/* /usr/share/icons
sudo cp -r $HOME/.themes/* /usr/share/themes

# Copy custom config
sudo cp -r $DOTFILES/lightdm /etc/

#####################
#       KITTY       #
#####################

KITTY_THEMES="$HOME/.config/kitty/themes"
KITTY_GIT="$CATPPUCCIN/kitty"

cp -r $DOTFILES/.config/kitty $HOME/.config

mkdir -p $KITTY_THEMES

# Clone Catppuccin theme for Rofi
if [[ ! -d "${KITTY_GIT}" ]]; then
    git -C $CATPPUCCIN clone https://github.com/Catppuccin/kitty.git
fi

# Create symlinks inside kitty theme folder
for FILE in $KITTY_GIT/themes/{frappe,mocha,latte,macchiato}.conf; do
    ln -s -T $FILE $KITTY_THEMES/$(basename -- $FILE)
done

# Apply theme
kitty +kitten themes --reload-in=all Catppuccin-Frappe

unset KITTY_THEMES
unset KITTY_GIT

#####################
#        ROFI       #
#####################

ROFI_THEMES=".local/share/rofi/themes"
ROFI_GIT="$CATPPUCCIN/rofi"

# Clone Catppuccin theme for Rofi
if [[ ! -d "${ROFI_GIT}" ]]; then
    git -C $CATPPUCCIN clone https://github.com/Catppuccin/rofi.git
fi

# Create required folders
mkdir -p $HOME/.config/rofi
mkdir -p $HOME/$ROFI_THEMES

# Create symlink for Catppuccin theme inside Rofi themes
for FILE in $ROFI_GIT/basic/$ROFI_THEMES/*; do
    ln -s -T "$FILE" "$HOME/$ROFI_THEMES/$(basename "$FILE")"
done

# Copy custom rofi config
cp -r "$DOTFILES/.config/rofi" "$HOME/.config"

# Bonus rofi themes
git -C "/tmp" clone "https://github.com/newmanls/rofi-themes-collection"
cp /tmp/rofi-themes-collection/themes/*.rasi "$HOME/$ROFI_THEMES"

unset ROFI_THEMES
unset ROFI_GIT

#####################
#      POLYBAR      #
#####################

# TODO

#####################
#      I3 SCROT     #
#####################

echo "scrot_dir=$HOME/Documents" > $HOME/.config/i3-scrot.conf

#####################
#      Thunar       #
#####################

cp -r $DOTFILES/.config/Thunar $HOME/.config
# Already done by Power Manager
# cp -r $DOTFILES/.config/xfce4 $HOME/.config

#####################
#       PICOM       #
#####################

cp $DOTFILES/.config/picom.conf $HOME/.config

#####################
#       DUNST       #
#####################

DUNST_GIT="$CATPPUCCIN/dunst"

# Clone Catppuccin theme for Dunst
if [[ ! -d "${DUNST_GIT}" ]]; then
    git -C $CATPPUCCIN clone https://github.com/Catppuccin/dunst.git
fi

# Copy custom config
cp -r $DOTFILES/.config/dunst $HOME/.config

# Append catppuccin theme to the end of the config file
cat "${DUNST_GIT}/src/frappe.conf" >> $HOME/.config/dunst/dunstrc

# Restart dunst
killall dunst
dunst &

unset DUNST_GIT

#####################
#       CLIPIT      #
#####################

cp -r $DOTFILES/.config/clipit $HOME/.config

#####################
#    WALLPAPERS     #
#####################

_ladislus_wallpaper_random

#####################
#   BETTERDISCORD   #
#####################

DISCORD_THEMES="$HOME/.config/BetterDiscord/themes"
DISCORD_GIT="$CATPPUCCIN/discord"

# Clone Catppuccin theme for Rofi
if [[ ! -d "$DISCORD_GIT" ]]; then
    git -C $CATPPUCCIN clone https://github.com/Catppuccin/discord.git
fi

# Launch discord to generate config files
# (The script won't continue unless the user close discord)
discord

# Install betterdiscord
betterdiscordctl install

# Copy custom config
cp -r $DOTFILES/.config/BetterDiscord $HOME/.config

# Create required folder in case it doesn't exist
mkdir -p $DISCORD_THEMES

# Create symlink for catppuccin themes
for FILE in $DISCORD_GIT/themes/*.theme.css; do
    ln -s -T $FILE $DISCORD_THEMES/$(basename -- $FILE)
done

unset DISCORD_THEMES
unset ROFI_GIT

#####################
#     SPICETIFY     #
#####################

# Download spicetify-themes
_ladislus_spicetify_download
# Set theme
_ladislus_spicetify_theme

#####################
#        GIT        #
#####################

wget -P "$GIT" "https://gist.githubusercontent.com/Ladislus/cedb8a5107d591ea308b23beb40e647b/raw/GithubFetchAll.py"
# POST: execute fetchall (can't use without adding SSH key before)

#####################
#     RUSTYVIBES    #
#####################

cargo install rustyvibes

#####################
#       YT-DLP      #
#####################

YTDLP_GIT="$GIT/yt-dlp"

# If yt-dlp is not cloned, clone it
if [[ ! -d "$YTDLP_GIT" ]]; then
    git -C "$GIT" clone "https://github.com/yt-dlp/yt-dlp.git"
fi

# build yt-dlp from sources
cd $YTDLP_GIT
make yt-dlp

# create symlink
ln -s -T "$YTDLP_GIT/yt-dlp" "$HOME/.local/bin/yt-dlp"

unset YTDLP_GIT

#####################
#      FOLDERS      #
#####################

# Remove config folders left by removed programs
CONFIG_FOLDERS=(pcmanfm morc_menu Kvantum epdfview dmenu-recent ranger libfm Mousepad)
for FOLDER in $CONFIG_FOLDERS; do
    echo "Removing '$HOME/.config/$FOLDER'"
    rm -rf "$HOME/.config/$FOLDER" 2> /dev/null
done

unset FOLDER
unset CONFIG_FOLDERS

# Remove folders left by removed programs + default folders
HOME_FOLDERS=('.moonchild productions' .urxvt .moc .mozilla Music Pictures Public Templates Videos)
for FOLDER in $HOME_FOLDERS; do
    echo "Removing '$HOME/$FOLDER'"
    rm -rf $HOME/$FOLDER 2> /dev/null
done

unset FOLDER
unset HOME_FOLDERS

# Remove config files in $HOME
HOME_FILES=(.xsession-errors.old .shell.pre-oh-my-zsh .zshrc.pre-oh-my-zsh .dmenurc .profile.bak)
for FILE in $HOME_FILES; do
    echo "Removing '$HOME/$FILE'"
    rm -rf "$HOME/$FILE" 2> /dev/null
done

unset FILE
unset HOME_FILES

# Remove unneeded folders in $HOME/.local/share
SHARE_FOLDERS=(moc ranger Mousepad)
for FOLDER in $SHARE_FOLDERS; do
    echo "Removing '$HOME/.local/share/$FOLDER'"
    rm -rf $HOME/.local/share/$FOLDER 2> /dev/null
done

unset FOLDER
unset SHARE_FOLDERS
