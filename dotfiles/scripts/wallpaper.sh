# Function to set a random wallpaper from a given directory
# [REQ] _ladislus_wallpaper_set
# [IN]  DIR:    The path to a valid directory (DEFAULT: $WALLPAPER)
# [ERR] (1) Missing required program
#       (2) Missing parameter
#       (3) Env variable $WALLPAPER is not available
#       (4) Provided directory path is invalid
#       (5) Provided directory contains no valid file
#       (6) Setting wallpaper failed
function _ladislus_wallpaper_random {
    # Assert that required programs are available
    _ladislus_utils_require _ladislus_wallpaper_set || return 1

    # Check if there is at most one argument
    if [ $# -gt 1 ]; then
        _ladislus_utils_error "Usage: $0 [wallpaper directory]?"
        _ladislus_utils_error "Got: $@"
        return 2
    fi

    # Check that $WALLPAPERS env variable is set
    if [ -z "$WALLPAPERS" ]; then
        _ladislus_utils_error "Missing env variable \$WALLPAPERS which is default value"
        return 3
    fi

    # Copy first parameter to a local variable, or use default
    local DIR="${1:-$WALLPAPERS}"

    # Check that the provided directory is valid
    if [ ! -d "$DIR" ]; then
        _ladislus_utils_error "'$DIR' is not a valid directory"
        return 4
    fi

    # Collect PNG & JPG files present in the directory
    local WF=($DIR/*.{png,jpg}(N))

    # No valid wallpaper file were found
    if [ "${#WF}" -eq 0 ]; then
        _ladislus_utils_error "'$DIR' doesn't contain any valid wallpaper"
        return 5
    fi

    # Select one wallpaper at random from the wallpaper files
    local WS=${WF[ $(($RANDOM % ${#WF[@]} + 1)) ]}

    # Set the selected wallpaper
    _ladislus_wallpaper_set "$WS" || return 6

    # unset local variables
    unset DIR
    unset WF
    unset WS
}

# Function to set a wallpaper
# [REQ] nitrogen cp
# [IN]  DIR:    The path to a valid directory (DEFAULT: $WALLPAPER)
# [ERR] (1) Missing required program
#       (2) Missing parameter
#       (3) Provided file is invalid
#       (4) Setting wallpaper failed
#       (5) Setting login wallpaper failed
function _ladislus_wallpaper_set {
    # Assert that required programs are available
    _ladislus_utils_require_multiple _ladislus_wallpaper_set sudo cp || return 1

    # Check if there is at most one argument
    if [ $# -gt 1 ]; then
        _ladislus_utils_error "Usage: $0 [wallpaper file]"
        _ladislus_utils_error "Got: $@"
        return 2
    fi

    # Copy first parameter to a local variable
    local W="${1:?"Error: Missing parameter 1"}"

    # Check that the provided file is valid
    if [ ! -f "$W" ]; then
        _ladislus_utils_error "'$W' is not a valid file"
        return 3
    fi

    # Change desktop wallpaper
    nitrogen --save --set-scaled "$W" || return 4

    # Change login wallpaper
    sudo cp "$W" "/usr/share/backgrounds/background.png" || return 5

    # unset local variables
    unset W
}