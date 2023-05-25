# Function to launch packages update
# [REQ] pamac cut grep
# [ERR] (1) Missing required program
#       (2) Missing parameter(s)
#       (3) Package removal failed
function _ladislus_package_remove {
# Assert that required programs are available
    _ladislus_utils_require_multiple pamac cut grep || return 1

    # Check if there at least one argument
    if [[ "$#" -eq 0 ]]; then
        _ladislus_utils_error "Usage: $0 [package name]+"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Collect parameters
    local PARAMS=("$@")

    # Initialise list of effectively installed packages to remove
    local TOREMOVE=()

    for _X in $PARAMS; do
        # Check if the package is installed
        if [[ $(pamac list -i | cut -d' ' -f1 | grep -w "$_X") ]]; then
            # If so, add to list
            TOREMOVE+="$_X"
        fi
    done

    # If there is packages to remove, remove them with pamac
    if [[ "${#TOREMOVE[@]}" -ne 0 ]]; then
        pamac remove "$TOREMOVE[@]" || return 3
    fi
}

# Function to launch packages update
# [REQ] pip pip3 cut tr awk xargs
# [ERR] (1) Missing required program
#       (2) Too many parameters
function _ladislus_package_pamac_update {
    # Assert that required programs are available
    _ladislus_utils_require pamac || return 1

    # Check if there is no argument
    if [[ "$#" -ne 0 ]]; then
        _ladislus_utils_error "Usage: $0"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Launch pip update
    _ladislus_utils_println "\n\t\t### Packages ###\n"
    pamac update --no-confirm
    pamac remove -o --no-confirm

    # Pamac returns 1 in case of "nothing to do", so need to override the return value
    return 0
}

# Function to launch Python update
# [REQ] pip pip3 cut tr awk xargs
# [ERR] (1) Missing required program
#       (2) Too many parameters
#       (3) Pip self-update failed
function _ladislus_package_python_update {
    # Assert that required programs are available
    _ladislus_utils_require_multiple pip pip3 cut tr awk xargs || return 1

    # Check if there is no argument
    if [[ "$#" -ne 0 ]]; then
        _ladislus_utils_error "Usage: $0"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Launch pip update
    _ladislus_utils_println "\n\t\t### Rust ###\n"
    pip install --upgrade pip || return 3
    pip3 list -o | cut -f1 -d' ' | tr " " "\n" | awk '{if(NR>=3)print}' | cut -d' ' -f1 | xargs -n1 pip3 install -U 2> /dev/null
}

# Function to launch Rust update
# [REQ] rustup
# [ERR] (1) Missing required program
#       (2) Too many parameters
#       (3) Rust update failed
function _ladislus_package_rust_update {
    # Assert that required programs are available
    _ladislus_utils_require rustup || return 1

    # Check if there is no argument
    if [[ "$#" -ne 0 ]]; then
        _ladislus_utils_error "Usage: $0"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Launch rustup update
    _ladislus_utils_println "\n\t\t### Rust ###\n"
    rustup update || return 3
}

# Function to launch OMZ update
# [REQ] omz
# [ERR] (1) Missing required program
#       (2) Too many parameters
#       (3) OMZ update failed
function _ladislus_package_omz_update {
    # Assert that required programs are available
    _ladislus_utils_require omz || return 1

    # Check if there is no argument
    if [[ "$#" -ne 0 ]]; then
        _ladislus_utils_error "Usage: $0"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Launch omz update
    _ladislus_utils_println "\n\t\t### OMZ ###\n"
    omz update || return 3
}

# Function to launch system update
# [REQ] _ladislus_package_pamac_update _ladislus_package_python_update _ladislus_package_rust_update _ladislus_package_omz_update
# [ERR] (1) Missing required program
#       (2) Too many parameters
#       (3) Pamac update failed
#       (4) Python update failed
#       (5) Rust update failed
#       (6) OMZ update failed
function _ladislus_package_update {
    # Assert that required programs are available
    _ladislus_utils_require_multiple _ladislus_package_pamac_update _ladislus_package_python_update _ladislus_package_rust_update _ladislus_package_omz_update || return 1

    # Check if there is no argument
    if [[ "$#" -ne 0 ]]; then
        _ladislus_utils_error "Usage: $0"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Launch updates
    _ladislus_package_pamac_update || (_ladislus_utils_error "Pamac update failed with code: '$?'" && return 3)
    _ladislus_package_python_update || (_ladislus_utils_error "Python update failed with code: '$?'" && return 4)
    _ladislus_package_rust_update || (_ladislus_utils_error "Rust update failed with code: '$?'" && return 5)
    _ladislus_package_omz_update || (_ladislus_utils_error "OMZ update failed with code: '$?'" && return 6)
}