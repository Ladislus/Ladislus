# Function to create a ZIP copy of all CBZ files inside a given folder
# [REQ] cp basename
# [IN]  IF:     The path to a valid folder
# [ERR] (1) Missing required program
#       (2) Missing parameter
#       (3) $IF is not a valid path to a valid directory
#       (4) No CBZ files in $IF
#       (5) cp command failed
function _ladislus_ebook_cbz_to_zip {
    # Assert that required programs are available
    _ladislus_utils_require_multiple cp basename || return 1

    # Check if there one argument
    if [[ $# -ne 1 ]]; then
        _ladislus_utils_error "Usage: $0 [folder containing the CBZ files]"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Copy input folder path to local variable, removing trailing '/' if present
    local IF="${${1:?"Error: Missing parameter 1"}%/}"

    # Assert that the input folder is valid
    if [[ ! -d "$IF" ]]; then
        _ladislus_utils_error "Path '$IF' isn't a valid folder"
        return 3
    fi

    # Collect all CBZ files inside the provided folder
    local FILES=($IF/*.cbz(N))
    local LEN=${#FILES[@]}

    # If there is no files, return error
    if [[ "$LEN" -eq 0 ]]; then
        _ladislus_utils_error "No CBZ file in '$IF'"
        return 4
    fi

    for _X in {1..$LEN}; do
        local FILE="${FILES[$_X]}"
        # Compute the name of the equivalent ZIP file
        local TARGET="${FILE/.cbz/.zip}"

        # If $TARGET file already exists, skip
        [[ -f "$TARGET" ]] && continue

        _ladislus_utils_print_interactive "[$_X/$LEN] Converting to zip: '$(basename $FILE)'"
        # Copy $FILE with a zip extension instead (as CBZ are just zipped photos), or return error on failure
        cp "$FILE" "$TARGET" || return 5
    done

    _ladislus_utils_println_interactive "Successfully converted $LEN CBZ files to ZIP"
}

# Function to unzip all ZIP files inside a given folder
# [REQ] basename unzip
# [IN]  IF:     The path to a valid folder
# [ERR] (1) Missing required program
#       (2) Missing parameter
#       (3) $IF is not a valid path to a valid directory
#       (4) No ZIP files in $IF
#       (5) unzip command failed
function _ladislus_ebook_extract {
    # Assert that required program are available
    _ladislus_utils_require_multiple basename unzip || return 1

    # Check if there one argument
    if [[ $# -ne 1 ]]; then
        _ladislus_utils_error "Usage: $0 [folder containing the ZIP files]"
        _ladislus_utils_error "Got: '$@'"
        return 2
    fi

    # Copy input folder path to local variable, removing trailing '/' if present
    local IF="${${1:?"Error: Missing parameter 1"}%/}"

    # Assert that the input folder is valid
    if [[ ! -d "$IF" ]]; then
        _ladislus_utils_error "Path '$IF' isn't a valid folder"
        return 3
    fi

    # Collect all CBZ files inside the provided folder
    local FILES=($IF/*.zip(N))
    local LEN=${#FILES[@]}

    # If there is no files, return error
    if [[ "$LEN" -eq 0 ]]; then
        _ladislus_utils_error "No ZIP file in '$IF'"
        return 4
    fi

    for _X in {1..$LEN}; do
        local FILE="${FILES[$_X]}"
        # Compute the name of the equivalent ZIP file
        local TARGET="${FILE/.zip/}"

        # If $TARGET folder already exists, skip
        [[ -d "$TARGET" ]] && continue

        _ladislus_utils_print_interactive "[$_X/$LEN] Unzipping '$(basename $FILE)'"

        # unzip $FILE zip into a folder with the same name, or return error on failure
        unzip "$FILE" -d "$TARGET" > /dev/null || return 5
    done

    _ladislus_utils_println_interactive "Successfully extracted $LEN ZIP files"
}

# Function to merge all images inside a directory into a single PDF file
# [REQ] getopt convert basename img2pdf rm
# [IN]  IF:     The path to a valid folder
# [FLG] -h | --help:            Display help and exit
# [FLG] -s | --skip-convert:    skip the image convertion phase (might provoke error later)
# [FLG] -o | --ouput:           Change the output directory for the generated PDF
# [ERR] (1) Missing required program
#       (2) getopt command failed
#       (3) Unrecognized option
#       (4) Missing parameter
#       (5) $IF is not a valid path to a valid directory
#       (6) $OF is not a valid path to a valid directory
#       (7) Destination PDF already exists
#       (8) $IF doesn't contain any image file to convert
#       (9) Convert command failed
#       (10) $IF doesn't contain any image file
#       (11) img2pdf command failed
#       (12) Temporary files removal failed
function _ladislus_ebook_pdfy {
    # Assert that required program are available
    _ladislus_utils_require_multiple getopt convert basename img2pdf rm || return 1

    # For some reason, assigning to local variable override the return code of 'getopt', so we can't trap invalid options
    _X=$(getopt -o hso: -l help,skip-convert,output: -n "$0" -- "$@")

    # If getopt failed, return error
    if [[ $? -ne 0 ]]; then
        _ladislus_utils_error "getopt failed"
        return 2
    fi

    # Set getopt result as function parameters
    eval set -- "$_X"

    # Store usage string as multiple elements can trigger it
    local USAGE="Usage: $0 [-s | --skip-output]? [-o | --output <output folder>] [folder containing the images]"

    # Set flags according to the command line
    local SC=false
    local OF=""
    while true; do
        case "$1" in
            -h | --help)
                _ladislus_utils_println "$USAGE"
                return 0
                ;;
            -s | --skip-convert)
                local SC=true
                shift
                ;;
            -o | --output)
                local OF="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                _ladislus_utils_error "Unrecognized option '$1'"
                return 3
        esac
    done

    # Check if there one argument
    if [[ $# -ne 1 ]]; then
        _ladislus_utils_error "$USAGE"
        _ladislus_utils_error "Got: '$@'"
        return 4
    fi

    # Copy input folder path to local variable, removing trailing '/' if present
    local IF="${${1:?"Error: Missing parameter 1"}%/}"
    # Copy output folder path to local variable, removing trailing '/' if present, or defaulting to $IF
    local OF="${${OF%/}:-$IF}"

    # Assert that the input folder is valid
    if [[ ! -d "$IF" ]]; then
        _ladislus_utils_error "Path '$IF' isn't a valid folder"
        return 5
    fi

    # Assert that the ouput folder is valid
    if [[ ! -d "$OF" ]]; then
        _ladislus_utils_error "Path '$OF' isn't a valid folder"
        return 6
    fi

    # Compute PDF name and path
    local PDF="$OF/$(basename $IF).pdf"

    # Check that the output PDF doesn't already exist
    if [[ -f "$PDF" ]]; then
        _ladislus_utils_error "Path '$PDF' already exists"
        return 7
    fi

    # Enable extended wildcards in case it isn't already
    setopt EXTENDED_GLOB

    # If the skip-convert flag wasn't set, convert all files beforehand
    if [[ "$SC" = false ]]; then
        # Collect all picture files inside the provided folder
        local FILES=($IF/*.{png,jpg,jpeg}~$IF/converted_*(N))
        local LEN=${#FILES[@]}

        # If there is no files, return error
        if [[ "$LEN" -eq 0 ]]; then
            _ladislus_utils_error "No images to convert in '$IF'"
            return 8
        fi

        for _X in {1..$LEN}; do
            local FILE="$(basename ${FILES[$_X]})"
            # Compute the name of the equivalent ZIP file
            local TARGET="converted_${FILE}"

            # If $TARGET folder already exists, skip
            [[ -f "$IF/$TARGET" ]] && continue

            _ladislus_utils_print_interactive "[$_X/$LEN] Converting '$FILE'"

            # convert $FILE to normalized format
            convert "$IF/$FILE" -background white -alpha remove -alpha off "$IF/$TARGET" || return 9;
        done

        _ladislus_utils_println_interactive "Done converting $LEN file(s)"

        # Collect all converted images
        local FILES=($IF/converted_*.{png,jpg,jpeg}(N))
        local LEN=${#FILES[@]}
    else
        # Collect all images
        local FILES=($IF/*.{png,jpg,jpeg}~$IF/converted_*(N))
        local LEN=${#FILES[@]}
    fi

    # If there is no files, return error
    if [[ "$LEN" -eq 0 ]]; then
        _ladislus_utils_error "No images to merge into a PDF in '$IF'"
        return 10
    fi

    # Sort file list by alphabetical order
    local FILES=(${(on)FILES})

    # Merge images into a single PDF
    _ladislus_utils_print "Merging $LEN images into '$PDF'"
    img2pdf -o "$PDF" -s A4 "$FILES[@]" || return 11
    _ladislus_utils_println " ✓"

    # If we used conversion, remove temporary converted files
    if [[ "$SC" = false ]]; then
        _ladislus_utils_print "Removing $LEN temporary file(s)"
        rm "$FILES[@]" || return 12
        _ladislus_utils_println " ✓"
    fi
}

# Function to pdfy all CBZ/ZIP/subfolders inside a given folder
# [REQ] getopt wc basename
# [IN]  IF:     The path to a valid folder
# [FLG] -h | --help:            Display help and exit
# [FLG] -s | --skip-convert:    skip the image convertion phase (might provoke error later)
# [FLG] -o | --ouput:           Change the output directory for the generated PDFs
# [ERR] (1) Missing required program
#       (2) getopt command failed
#       (3) Unrecognized option
#       (4) Missing parameter
#       (5) $IF is not a valid path to a valid directory
#       (6) $OF is not a valid path to a valid directory
function _ladislus_ebook_generate {
    # Assert that required program are available
    _ladislus_utils_require_multiple getopt basename || return 1

    # For some reason, assigning to local variable override the return code of 'getopt', so we can't trap invalid options
    _X=$(getopt -o hso: -l help,skip-convert,output: -n "$0" -- "$@")

    # If getopt failed, return error
    if [[ $? -ne 0 ]]; then
        _ladislus_utils_error "getopt failed"
        return 2
    fi

    # Set getopt result as function parameters
    eval set -- "$_X"

    # Store usage string as multiple elements can trigger it
    local USAGE="Usage: $0 [-s | --skip-output]? [-o | --output <output folder>] [folder containing the CBZ/ZIP/Subfolders]"

    # Set flags according to the command line
    local SC=false
    local OF=""
    while true; do
        case "$1" in
            -h | --help)
                _ladislus_utils_println "$USAGE"
                return 0
                ;;
            -s | --skip-convert)
                local SC=true
                shift
                ;;
            -o | --output)
                local OF="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                _ladislus_utils_error "Unrecognized option '$1'"
                return 3
        esac
    done

    # Check if there one argument
    if [[ $# -ne 1 ]]; then
        _ladislus_utils_error "$USAGE"
        _ladislus_utils_error "Got: '$@'"
        return 4
    fi

    # Copy input folder path to local variable, removing trailing '/' if present
    local IF="${${1:?"Error: Missing parameter 1"}%/}"
    # Copy output folder path to local variable, removing trailing '/' if present, or defaulting to $IF
    local OF="${${OF%/}:-$IF}"

    # Assert that the input folder is valid
    if [[ ! -d "$IF" ]]; then
        _ladislus_utils_error "Path '$IF' isn't a valid folder"
        return 5
    fi

    # Assert that the ouput folder is valid
    if [[ ! -d "$OF" ]]; then
        _ladislus_utils_error "Path '$OF' isn't a valid folder"
        return 6
    fi

    # TODO: Implement the rest
    # 1 => Convert CBZ
    # 2 => Unzip ZIP
    # 3 => Collect all folder names
    # 4 => Check that some folders doesn't contain a subfolder and if so remove the extra folder (some people zip a folder instead of the image directly to the root)
    # 5 => pdfy all folders
}