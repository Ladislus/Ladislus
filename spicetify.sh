# Permissions de modification des fichiers de Spotify
sudo chmod a+wr /opt/spotify -R
# Téléchargement des themes
cd ~/.config/spicetify/Themes/
git clone https://github.com/morpheusthewhite/spicetify-themes
mv -r spicetify-themes/* .
rm -rf spicetify-themes LICENSE README.md CODE_OF_CONDUCT.md .gitignore
# Mise à jour de Spotify
spicetify backup apply enable-devtool
spicetify config current_theme Onepunch
spicetify apply disable-devtool
