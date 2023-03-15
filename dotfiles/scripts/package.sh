function _ladislus_package_remove {

    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    local TOREMOVE

    for P in $@;
    do
        # Check if the package is installed
        if [[ $(pamac list -i | cut -d' ' -f1 | grep -w "${P}") ]];
        then
            # If not, add to list
            TOREMOVE+=$P
        fi
    done

    if [[ ! -z "${TOREMOVE}" ]];
    then
        # Remove list
        pamac remove $TOREMOVE
    fi

    unset TOREMOVE
}

function _ladislus_package_pamac_update {
    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    echo '	############'
    echo '	# PACKAGES #'
    echo '	############\n'
    pamac update --no-confirm
    pamac remove -o --no-confirm
}

function _ladislus_package_python_update {
    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    echo '\n	##########'
    echo '	# PYTHON #'
    echo '	##########\n'
    pip install --upgrade pip
    pip3 list -o | cut -f1 -d' ' | tr " " "\n" | awk '{if(NR>=3)print}' | cut -d' ' -f1 | xargs -n1 pip3 install -U 2> /dev/null
}

function _ladislus_package_rust_update {
    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    echo '\n	########'
    echo '	# RUST #'
    echo '	########\n'
    rustup update
}

function _ladislus_package_omz_update {
    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    echo '\n	#######'
    echo '	# OMZ #'
    echo '	#######\n'
    omz update
}

function _ladislus_package_update {
    # Check if there is no argument
    if [ $# -ne 0 ]; then
        >&2 echo "No argument expected, got '$@'"
        return 1
    fi

    _ladislus_package_pamac_update
    _ladislus_package_python_update
    _ladislus_package_rust_update
    _ladislus_package_omz_update
}