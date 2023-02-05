# Make sure directory exist
has_directory() {
    if [ -z "$1" ]; then
        System.die "Directory name can not be null!"
    fi
    if [ ! -d "$1" ]; then
        System.die "No such directory: \"$1\""
    fi
}

# Make sure directories exist
has_directories() {
    for i in "$@"; do
        has_directory "$i"
    done
}

# Make sure file/directory exist
has() {
    if [ -z "$1" ]; then
        System.die "File/directory Name can not be null!"
    fi
    if [ ! -e "$1" ]; then
        System.die "No such file/directory: \"$1\""
    fi
}

# The first path must be in the second path
file_exist_in() {
    if ! [[ "$1" == "$2" ]] && ! [[ "$1" == "$2"/* ]]; then
        System.die "$1 no in $2"
    fi
}

# Copy file with progress
copy() {
    rsync -r -W --progress "$1" "$2"
}

get_absolute_path() {
    if [ ! -e "$1" ]; then System.die "Can not get a absolute path of thing that doesn't exist!"; fi
    if [ -f "$1" ]; then
        echo $(cd "$(dirname "$1")" 2>&1 && pwd -P)"/`basename "$1"`"
    else
        echo $(cd "$1" 2>&1 && pwd -P)
    fi
}