function _ladislus_wallpaper_random {

    # Check if there is at most one argument
    if [ $# -gt 1 ]; then
        >&2 echo "Expected at most one argument (wallpaper directory), got '$@'"
        return 1
    fi

    local DIR=${1:-$WALLPAPERS}

    if [[ ! -d "${DIR}" ]]; then
        >&2 echo "Expected at most one argument (wallpaper directory), got '$@'"
        return 1
    fi

    local WALLPAPER_FILES=($DIR/*.{png,jpg})
    local WALLPAPER_SELECTED=${WALLPAPER_FILES[ $(($RANDOM % ${#WALLPAPER_FILES[@]} + 1)) ]}

    _ladislus_wallpaper_set $WALLPAPER_SELECTED

    unset DIR
    unset WALLPAPER_FILES
    unset WALLPAPER_SELECTED
}

function _ladislus_wallpaper_set {

    # Check if there is exactly one argument
    if [ $# -ne 1 ]; then
        >&2 echo "Only one argument expected (file to set as wallpaper); got '$@'"
        return 1
    fi

    # Change desktop wallpaper
    nitrogen --save --set-scaled "$1"

    # Change login wallpaper
    sudo cp "$1" "/usr/share/backgrounds/background.png"
}