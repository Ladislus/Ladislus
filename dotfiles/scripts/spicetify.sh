SPICETIFY=$HOME/.spicetify

function _ladislus_spicetify_symlink {

    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    for ELEMENT in $SPICETIFY/*
    do
        if [[ -d "${ELEMENT}" ]]
        then
            ln -s -T $ELEMENT "$HOME/.config/spicetify/Themes/$(basename -- $ELEMENT)"
        fi
    done
}

function _ladislus_spicetify_download {

    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    # If the git repository doesn't exist, clone it
    if [[ ! -d $SPICETIFY ]];
    then
        git -C $HOME clone https://github.com/morpheusthewhite/spicetify-themes $SPICETIFY
        _ladislus_spicetify_symlink
    else
        # Else, update it
        _ladislus_spicetify_update
    fi
}

function _ladislus_spicetify_update {
    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    # Update git repository
    git -C $SPICETIFY pull

    # Reset symlinks
    rm -f $HOME/.config/spicetify/Themes/*
    _ladislus_spicetify_symlink
}

function _ladislus_spicetify_theme {

    # Check if there is at most one argument
    if [ $# -gt 1 ]; then
        >&2 echo "Expected at most one argument (theme name), got '$@'"
        return 1
    fi

    # If no parameter is provided, default to "BurntSierra"
    local SPICETIFY_THEME=${1:-BurntSienna}

    # Set permissions to change spotify look
    sudo chmod a+wr /opt/spotify -R

    # Set Spotify theme
    spicetify backup apply
    spicetify config current_theme $SPICETIFY_THEME
    spicetify apply

    unset SPICETIFY_THEME
}