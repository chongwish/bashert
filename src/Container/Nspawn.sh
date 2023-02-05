
BASHERT_CONTAINER_NSPAWN_NAME=""

name() {
    if [ -z "$1" ]; then
        System.die "Container name can not be null!"
    fi
    BASHERT_CONTAINER_NSPAWN_NAME="$1"
}

get_name() {
    has_name
    ret "$BASHERT_CONTAINER_NSPAWN_NAME"
}

has_name() {
    if [ -z "$BASHERT_CONTAINER_NSPAWN_NAME" ]; then
        System.die "Set container name first!"
    fi
}

is_mounted() {
    if [ -n "`exec_command "findmnt -ln -o 'SOURCE' '$1'"`" ]; then
        return 0;
    fi
    return 1
}

exec_command() {
    machinectl shell -q $BASHERT_CONTAINER_NSPAWN_NAME /bin/sh -c "$@"
}