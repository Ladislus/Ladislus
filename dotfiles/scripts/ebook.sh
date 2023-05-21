# Function to unzip all ZIP files inside a given folder
# [REQ] basename unzip
# [IN]  IF:     The path to a valid folder
# [ERR] (1) Missing required program
#       (2) Missing parameter
#       (3) $IF is not a valid path to a valid directory
#       (4) unzip command failed
function _ladislus_ebook_extract_zip {
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
        _ladislus_utils_println "No ZIP file in '$IF'"
        return 0
    fi

    for _X in {1..$LEN}; do
        local FILE="${FILES[$_X]}"
        # Compute the name of folder equivalent to the ZIP file
        local TARGET="${FILE/.zip/}"

        # If $TARGET folder already exists, skip
        [[ -d "$TARGET" ]] && continue

        _ladislus_utils_print_interactive "[$_X/$LEN] Unzipping '$(basename $FILE)'"

        # unzip $FILE zip into a folder with the same name, or return error on failure
        unzip "$FILE" -d "$TARGET" > /dev/null || return 4
    done

    _ladislus_utils_println_interactive "Successfully extracted $LEN ZIP files"
}

# Function to unzip all CBZ files inside a given folder
# [REQ] basename 7z
# [IN]  IF:     The path to a valid folder
# [ERR] (1) Missing required program
#       (2) Missing parameter
#       (3) $IF is not a valid path to a valid directory
#       (4) 7z command failed
function _ladislus_ebook_extract_cbz {
    # Assert that required program are available
    _ladislus_utils_require_multiple basename 7z || return 1

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

    # If there is no files, early return
    if [[ "$LEN" -eq 0 ]]; then
        _ladislus_utils_println "No CBZ file in '$IF'"
        return 0
    fi

    for _X in {1..$LEN}; do
        local FILE="${FILES[$_X]}"
        # Compute the name of folder equivalent to the CBZ file
        local TARGET="${FILE/.zip/}"

        # If $TARGET folder already exists, skip
        [[ -d "$TARGET" ]] && continue

        _ladislus_utils_print_interactive "[$_X/$LEN] Unzipping '$(basename $FILE)'"

        # use 7z to unzip $FILE cbz into a folder with the same name, or return error on failure
        7z x "$FILE" -o"$TARGET" > /dev/null || return 4
    done

    _ladislus_utils_println_interactive "Successfully extracted $LEN ZIP files"
}

# Function to merge all images inside a directory into a single PDF file
# [REQ] getopt convert basename img2pdf rm
# [IN]  IF:     The path to a valid folder
# [FLG] -h | --help:            Display help and exit
# [FLG] -s | --skip-convert:    skip the image convertion phase (might provoke error later)
# [FLG] -o | --ouput:           Change the output directory for the generated PDF
# [FLG] -f | --force:           If the PDF already exist, override it
# [ERR] (1) Missing required program
#       (2) getopt command failed
#       (3) Unrecognized option
#       (4) Missing parameter
#       (5) $IF is not a valid path to a valid directory
#       (6) $OF is not a valid path to a valid directory
#       (7) $IF doesn't contain any image file to convert
#       (8) Convert command failed
#       (9) $IF doesn't contain any image file
#       (10) img2pdf command failed
#       (11) Temporary files removal failed
function _ladislus_ebook_pdfy {
    # Assert that required program are available
    _ladislus_utils_require_multiple getopt convert basename img2pdf rm || return 1

    # For some reason, assigning to local variable override the return code of 'getopt', so we can't trap invalid options
    _X=$(getopt -o hso:f -l help,skip-convert,output:,force -n "$0" -- "$@")

    # If getopt failed, return error
    if [[ $? -ne 0 ]]; then
        _ladislus_utils_error "getopt failed"
        return 2
    fi

    # Set getopt result as function parameters
    eval set -- "$_X"

    # Store usage string as multiple elements can trigger it
    local USAGE="Usage: $0 [-s | --skip-output]? [-f | --force]? [-o | --output <output folder>] [folder containing the images]"

    # Set flags according to the command line
    local SC=false
    local OF=""
    local FORCE=false
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
            -f | --force)
                local FORCE=true
                shift
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
        _ladislus_utils_error "Got: '$_X'"
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

    #
    if [[ "$FORCE" = false && -f "$PDF" ]]; then
        _ladislus_utils_println "PDF '$PDF' already exists"
        return 0
    fi

    if [[  "$FORCE" = true && -f "$PDF" ]]; then
        _ladislus_utils_println "PDF '$PDF' already exists, overwriting it"
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
            return 7
        fi

        for _X in {1..$LEN}; do
            local FILE="$(basename ${FILES[$_X]})"
            # Compute the name of the equivalent ZIP file
            local TARGET="converted_${FILE}"

            # If $TARGET folder already exists, skip
            [[ -f "$IF/$TARGET" ]] && continue

            _ladislus_utils_print_interactive "[$_X/$LEN] Converting '$IF/$FILE'"

            # convert $FILE to normalized format
            convert "$IF/$FILE" -background white -alpha remove -alpha off "$IF/$TARGET" || return 8;
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
        return 9
    fi

    # Sort file list by alphabetical order
    local FILES=(${(on)FILES})

    # Merge images into a single PDF
    _ladislus_utils_print "Merging $LEN images into '$PDF'"
    img2pdf -o "$PDF" -s A4 "$FILES[@]" || return 11
    _ladislus_utils_println_interactive "Merged $LEN images into '$PDF'"

    # If we used conversion, remove temporary converted files
    if [[ "$SC" = false ]]; then
        _ladislus_utils_print "Removing $LEN temporary file(s)"
        rm "$FILES[@]" || return 11
        _ladislus_utils_println_interactive "Removed $LEN temporary file(s)"
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
#       (7) ZIP extraction failed
#       (8) CBZ extraction failed
#       (9) Subfolder cleaning failed
#       (10) PDF generation fail
function _ladislus_ebook_generate {
    # Assert that required program are available
    _ladislus_utils_require_multiple getopt basename mv rm _ladislus_ebook_pdfy || return 1

    # For some reason, assigning to local variable override the return code of 'getopt', so we can't trap invalid options
    _X=$(getopt -o hso:f -l help,skip-convert,output:,force -n "$0" -- "$@")

    # If getopt failed, return error
    if [[ $? -ne 0 ]]; then
        _ladislus_utils_error "getopt failed"
        return 2
    fi

    # Set getopt result as function parameters
    eval set -- "$_X"

    # Store usage string as multiple elements can trigger it
    local USAGE="Usage: $0 [-s | --skip-output]? [-f | --force]? [-o | --output <output folder>] [folder containing the CBZ/ZIP/Subfolders]"

    # Set flags according to the command line
    local SC=false
    local OF=""
    local FORCE=false
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
            -f | --force)
                local FORCE=true
                shift
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
    # Copy output folder path to local variable, removing trailing '/' if present
    local OF="${OF%/}"

    # Assert that the input folder is valid
    if [[ ! -d "$IF" ]]; then
        _ladislus_utils_error "Path '$IF' isn't a valid folder"
        return 5
    fi

    # Assert that the ouput folder is valid, if given
    if [[ ! -z "$OF" && ! -d "$OF" ]]; then
        _ladislus_utils_error "Path '$OF' isn't a valid folder"
        return 6
    fi

    # Unzip all ZIP files into folders
    _ladislus_ebook_extract_zip "$IF" || return 7
    # Unzip all CBZ files into folders
    _ladislus_ebook_extract_cbz "$IF" || return 8

    # Collect all folders (excluding symlinks) and the count
    local FOLDERS=($IF/*(-/N))
    local FOLDER_LEN="${#FOLDERS[@]}"

    # Variable to count how many actual PDFs were generated
    local GEN_COUNT=0

    # Small output formatting to distinguish each pdfy call better
    _ladislus_utils_println

    for _X in {1..$FOLDER_LEN}; do

        # Copy current folder to intermediate variable
        local CUR="${FOLDERS[$_X]}"

        # Small output distinguish each pdfy call better
        _ladislus_utils_println "[$_X/$FOLDER_LEN] Treating folder '$CUR'"

        # While the current folder contains a subfolder (and nothing else),
        # remove this useless subfolder by copying all files inside it into the top folder
        while true; do
            # Collect all files in subfolder & the count
            local FILES=($CUR/*(N))
            local FILES_LEN="${#FILES[@]}"

            # If the subfolder is empty, display error and skip to the next one
            if [[ "$FILES_LEN" -eq 0 ]]; then
                _ladislus_utils_error "Folder '$CUR' is empty"

                # Small output formatting to distinguish each pdfy call better
                _ladislus_utils_println

                # Skip to next for loop iteration
                continue 2
            fi

            # Check that the current folder contains only a subfolder
            if [[ "$FILES_LEN" -eq 1 && -d "${FILES[1]}" ]]; then
                # Move files of the subfolder in the top directory and remove the subfolder
                (mv ${FILES[1]}/* "$CUR" && rm -rf "${FILES[1]}") || return 9
            else
                # The "subfolder cleaning" is done, we can generate the PDF
                break
            fi
        done

        # Generate the PDF
        _ladislus_ebook_pdfy $([[ "$SC" = true ]] && echo '-s') $([[ "$FORCE" = true ]] && echo '-f') -o "${OF:-$CUR}" "$CUR" || return 10

        # Increase the generation count
        local GEN_COUNT=$(($GEN_COUNT + 1))

        # Small output formatting to distinguish each pdfy call better
        _ladislus_utils_println
    done

    # Display how many PDF were generated
    _ladislus_utils_println "Genrated $GEN_COUNT PDF(s)"
}