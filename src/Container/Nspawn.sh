
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

find_mount_disk() {
    has_name

    var disk_path="`File.locate_disk_path "$1"`"

    local disk_name="${disk_path%%:*}"
    local relation_path="${disk_path#*:}"

    local mount_name
    mount_name="`exec_command "findmnt -ln -a -o TARGET,SOURCE | sed -rn 's|(.*)[[:space:]]+($disk_name)\[(/@rootfs)?$relation_path\]|\1|p'"`"
    mount_name="$(echo "$mount_name" | sed `printf 's/\s*\r$//g'`)"

    ret $mount_name
}

mount_disk() {
    :
}

umount_disk() {
    has_name

    exec_command "umount '$1' && rmdir '$1'"
}