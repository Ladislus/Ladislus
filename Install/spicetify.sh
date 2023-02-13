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