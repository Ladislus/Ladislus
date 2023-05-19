####################################################
#                        PATHS                     #
####################################################

# Function to extract the absolute path for a given path
# [REQ] 'dirname', 'realpath'
# [IN]  IP:     The path to a valid file or directory on the system
# [OUT] STDOUT: The absolute path of IP (without trailing '/')
# [ERR] (1) Missing required program
#       (2) IP is not a valid path to a valid file/directory
function _ladislus_path_absolute_path {

    # Assert that required programs are available
    _ladislus_utils_require_multiple dirname realpath || return 1

    # Copy input path
    local IP=${1:?"Error: Missing input path"}

    # If IP is a file, take the name of it's parent directory
    if [ -f $IP ]; then
        local IP=$(dirname $IP)
    else
        # If it's not a file, check that it's at least a valid directory
        if [ ! -d $IP ]; then
            _ladislus_utils_error "'$IP' is not a directory, nor a file"
            return 2
        fi
    fi

    # return the absolute path to STDOUT
    echo "$(realpath $IP)"

    # unset local variables
    unset IP
}

# Function to extract the filename (without extension) for a given path
# [REQ] basename
# [IN]  IF:     The path to a valid file
# [OUT] STDOUT: The filename of IF (without extension)
# [ERR] (1) Missing required program
#       (2) IF is not a valid path to a valid file
function _ladislus_path_filename {

    # Assert that required program is available
    _ladislus_utils_require basename || return 1

    # Copy input file
    local IF=${1:?"Error: Missing input file"}

    # Check that IF is a valid file
    if [ ! -f $IF ]; then
        _ladislus_utils_error "'$IF' is not a valid file"
        return 2
    fi

    # return the filename to STDOUT
    echo "${$(basename $IF)#*.}"

    # unset local variables
    unset IF
}

# Function to extract the extension (without leading '.') for a given path
# [REQ] basename
# [IN]  IF:     The path to a valid file
# [OUT] STDOUT: The extension of IF (without leading '.')
# [ERR] (1) Missing required program
#       (2) IF is not a valid path to a valid file
function _ladislus_path_extension {

    # Assert that required program is available
    _ladislus_utils_require basename || return 1

    # Copy input file
    local IF=${1:?"Error: Missing input file"}

    # Check that IF is a valid file
    if [ ! -f $IF ]; then
        _ladislus_utils_error "'$IF' is not a valid file"
        return 2
    fi

    # return the extension to STDOUT
    echo "${$(basename $IF)%%.*}"

    # unset local variables
    unset IF
}

# Function to create a copy of a given file with a new extension
# [REQ] _ladislus_path_absolute_path _ladislus_path_filename _ladislus_path_extension cp
# [IN]  IF:     The path to a valid file
# [IN]  EXT:    The extension of the copied file
# [OUT] STDOUT: The extension of IF (without leading '.')
# [ERR] (1) Missing required program
#       (2) IF is not a valid path to a valid file
#       (3) The IF splitting into (absolute directory path, filename, old extension) failed
#       (4) The new file extension is the same as the old one
#       (5) The file with the new extension already exists
function _ladislus_path_change_extension {

    # Assert that required programs are available
    _ladislus_utils_require_multiple _ladislus_path_absolute_path _ladislus_path_filename _ladislus_path_extension cp || return 1

    # Copy input file & wanted extension
    local IF="${1:?"Error: Missing original file path"}"
    local EXT="${${2:?"Error: Missing new extension"}#.*}"

    # Check that IF is a valid file
    if [ ! -f $IF ]; then
        _ladislus_utils_error "File '$IF' doesn't exist"
        return 2
    fi

    # Split IF into (absolute directory path, filename, old extension)
    local IF_DIRNAME="$(_ladislus_path_absolute_path "$IF")" || return 3
    local IF_FILENAME="$(_ladislus_path_filename "$IF")" || return 3
    local IF_EXTENSION="$(_ladislus_path_extension "$IF")" || return 3

    # Assert that the new extension is not the same as the actuel one
    if [ $EXT = $IF_EXTENSION ]; then
        _ladislus_utils_error "Input file '$IF' already has extension '$EXT'"
        return 4
    fi

    # Construct new path
    local NF="$IF_DIRNAME/$IF_FILENAME.$EXT"

    # Assert that the copy name doesn't collide with existing file
    if [ -f $NF ]; then
        _ladislus_utils_error "File '$NF' already exists"
        return 5;
    fi

    # Copy the file with the new entension
    cp $IF $NF

    # unset local variables
    unset IF
    unset IF_DIRNAME
    unset IF_FILENAME
    unset IF_EXTENSION
    unset NF
}

####################################################
#                   VALIDITY TESTS                 #
####################################################

# Function to check if path is valid
# [IN]  IP:     The path to test
# [ERR] (1) Path is invalid
function _ladislus_path_exists {
    [ -e ${1:?"Error: Missing input path"} ] && return 0 || return 1
}

# Function to check if path is valid file
# [IN]  IF:     The path to the file to test
# [ERR] (1) Path is invalid
function _ladislus_path_is_file {
    [ -f ${1:?"Error: Missing input path"} ] && return 0 || return 1
}

# Function to check if path is valid folder
# [IN]  IP:     The path to the folder test
# [ERR] (1) Path is invalid
function _ladislus_path_is_directory {
    [ -d ${1:?"Error: Missing input path"} ] && return 0 || return 1
}