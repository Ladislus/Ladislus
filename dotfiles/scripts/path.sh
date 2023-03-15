function _ladislus_path_add {

    # Check if there is exactly one argument
    if [ $# -ne 1 ]; then
        >&2 echo "Only one argument expected (path to add to PATH); got '$@'"
        return 1
    fi

    # Copy first (and only) parameter to a local variable, removing trailing slash if present
    local PARAM=${1%/}

    # Check if $PATH doesn't contain the substring (using regex)
    if ! [[ "$PATH" =~ (^|:)"${PARAM}"/?(:|$) ]]; then
        # Add to the PATH
        PATH="$PARAM:$PATH"
    fi

    unset PARAM
}