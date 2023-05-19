####################################################
#                      REQUIRES                    #
####################################################

# Function to check if a given program is available in the path
# [IN]  PROGRAM:     The program name
# [ERR] (1) Missing required program
function _ladislus_utils_require {
    # Copy program name
    local PROGRAM="${1:?"Error: Missing program name"}"

    # Check if the program execution would succeed
    if ! command -v $PROGRAM > /dev/null; then
        _ladislus_utils_error "Missing program '$PROGRAM'"
        return 1
    fi

    # unset local variables
    unset PROGRAM
}

# Function to check if multiple programs are available in the path
# [IN]  PROGRAMS*:      The program names
# [ERR] (1) Missing parameter
#       (2) Missing required program
function _ladislus_utils_require_multiple {
    # Check that at least one parameter was provided
    if [ $# -eq 0 ]; then
        _ladislus_utils_error "Function '$0' requires at least one argument"
        return 1
    fi

    # Collect parameters into an array
    local PROGRAMS=("$@")

    # Check that all provided program names are available
    for PROGRAM in $PROGRAMS; do
        _ladislus_utils_require $PROGRAM || return 2
    done

    # unset local variables
    unset PROGRAMS
}

####################################################
#                       PRINTS                     #
####################################################

# Function to print to STDERR
function _ladislus_utils_error {
    echo -e "[ERROR] $@" 1>&2
}

# Function to print to STDOUT without newline
function _ladislus_utils_print {
    echo -en "$@"
}

# Function to print to STDOUT without newline after cleaning the current line
function _ladislus_utils_print_interactive {
    _ladislus_utils_print "\r\033[K$@"
}

# Function to print to STDOUT with newline
function _ladislus_utils_println {
    echo -e "$@"
}

# Function to print to STDOUT with newline after cleaning the current line
function _ladislus_utils_println_interactive {
    _ladislus_utils_println "\r\033[K$@"
}