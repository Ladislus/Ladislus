# Function that create symlinks from spicetify_themes git to spicetify theme folder
# [REQ] ln
# [ERR] (1) Missing required program
#       (2) Too many parameters
#       (3) $SPICETIFY env varible is not available
#       (4) Spicetify theme folder doesn't exist
function _ladislus_spicetify_symlink {
    # Assert that required programs are available
    _ladislus_utils_require ln || return 1

    # Check if there is no argument
    if [[ $# -ne 0 ]]; then
        _ladislus_utils_error "Usage: $0"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Check that $SPICETIFY env variable is set
    if [[ -z "$SPICETIFY" ]]; then
        _ladislus_utils_error "Missing env variable \$SPICETIFY"
        return 3
    fi

    # Set spicetify theme folder
    local THEMES="$HOME/.config/spicetify/Themes"

    # Assert that spicetify theme folder exists
    if [[ ! -d "$THEMES" ]]; then
        _ladislus_utils_error "Spicetify theme folder doesn't exist"
        return 4
    fi

    # Create symlinks for directories
    for _X in $SPICETIFY/*/; do
        if [[ -d "$_X" ]]; then
            ln -s -T "$_X" "$THEMES/$(basename -- "$_X")"
        fi
    done
}

# Function that download (or update if already present) spicetify_themes git repository
# [REQ] git _ladislus_spicetify_symlink _ladislus_spicetify_update
# [ERR] (1) Missing required program
#       (2) Too many parameters
#       (3) $SPICETIFY env varible is not available
#       (4) Creating spicetify symlinks failed
#       (5) Updating spicetify_themes failed
function _ladislus_spicetify_download {
    # Assert that required programs are available
    _ladislus_utils_require_multiple git _ladislus_spicetify_symlink _ladislus_spicetify_update || return 1

    # Check if there is no argument
    if [[ $# -ne 0 ]]; then
        _ladislus_utils_error "Usage: $0"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Check that $SPICETIFY env variable is set
    if [[ -z "$SPICETIFY" ]]; then
        _ladislus_utils_error "Missing env variable \$SPICETIFY"
        return 3
    fi

    # If the git repository doesn't exist, clone it
    if [[ ! -d "$SPICETIFY" ]]; then
        git -C "$HOME" clone https://github.com/morpheusthewhite/spicetify-themes "$SPICETIFY"
        _ladislus_spicetify_symlink || return 4
    else
        # Else, update it
        _ladislus_spicetify_update || return 5
    fi
}


# Function that update spicetify_themes git repository
# [REQ] git _ladislus_spicetify_symlink
# [ERR] (1) Missing required program
#       (2) Too many parameters
#       (3) $SPICETIFY env varible is not available
#       (4) Updating spicetify_themes failed
#       (5) Resetting symlinks failed
function _ladislus_spicetify_update {
    # Assert that required programs are available
    _ladislus_utils_require_multiple git _ladislus_spicetify_symlink || return 1

    # Check if there is no argument
    if [[ $# -ne 0 ]]; then
        _ladislus_utils_error "Usage: $0"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Check that $SPICETIFY env variable is set
    if [[ -z "$SPICETIFY" ]]; then
        _ladislus_utils_error "Missing env variable \$SPICETIFY"
        return 3
    fi

    # Update git repository
    git -C "$SPICETIFY" pull || return 4

    # Reset symlinks
    rm -f "$HOME/.config/spicetify/Themes/*"
    _ladislus_spicetify_symlink || return 5
}

# Function that set spicetify theme
# [REQ] chmod spicetify
# [ERR] (1) Missing required program
#       (2) Missing parameters
#       (3) Couldn't change permission for Spotify
#       (4) Changing theme failed
function _ladislus_spicetify_theme {
    # Assert that required programs are available
    _ladislus_utils_require_multiple sudo chmod spicetify || return 1

    # Check if there at most one argument
    if [[ $# -gt 1 ]]; then
        _ladislus_utils_error "Usage: $0 [spicetify theme name]?"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # If no parameter is provided, default to "BurntSierra"
    local ST="${1:-BurntSienna}"

    # Set permissions to change spotify look
    sudo chmod a+wr /opt/spotify -R || return 3

    # Set Spotify theme
    spicetify backup apply || return 4
    spicetify config current_theme "$ST" || return 4
    spicetify apply || return 4
}