function _ladislus_ebook_cbz_to_zip {

    # Assert that required programs are available
    _ladislus_utils_require_multiple basename cp || return 1

    # Copy input folder name
    local IF="${${1:?"Error: Missing input folder"}%/}"

    # Assert that the input folder is valid
    if [ ! -d $IF ]; then
        _ladislus_utils_error "Path '$IF' isn't a valid folder"
        return 1
    fi

    local FILES=($IF/*.cbz(N))

    local LEN=${#FILES}
    local INDEX=1
    for FILE in $FILES; do

        local TARGET="${FILE/.cbz/.zip}"

        [ -f "$TARGET" ] && continue

        _ladislus_utils_print_interactive "[$INDEX/$LEN] Converting to zip: '$(basename $FILE)'"
        cp "$FILE" "${FILE/.cbz/.zip}"
        local INDEX=$(($INDEX + 1))
    done

    _ladislus_utils_println_interactive "Successfully converted $LEN CBZ files to ZIP"

    unset LEN
    unset INDEX
}

function _ladislus_ebook_folders {

    _ladislus_utils_require_multiple realpath unzip || return 1

    local INPUT_FOLDER="${${1:?"Error: Missing input folder"}%/}"

    if [ ! -d $INPUT_FOLDER ]; then
        _ladislus_utils_error "Path '$INPUT_FOLDER' isn't a valid folder" 1>&2
        return 1
    fi

    _ladislus_utils_println "Treating ZIP files inside: '$(realpath $INPUT_FOLDER)'"

    local FILES=($INPUT_FOLDER/*.zip(N))

    local LEN=${#FILES}
    local INDEX=1
    for F in $FILES; do
        local DEST="${F/.zip/}"
        _ladislus_utils_print_interactive "[$INDEX/$LEN] Unzipping '$F'"
        unzip "$F" -d "$DEST" > /dev/null
        local INDEX=$(($INDEX + 1))
    done

    _ladislus_utils_println_interactive "Successfully extracted $LEN ZIP files to folder '$(realpath $INPUT_FOLDER)'"

    unset LEN
    unset INDEX
}

function _ladislus_ebook_pdfy {
    # TODO: Copy from pdfy.sh
    return 1
}