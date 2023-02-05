
BASHERT_CONTAINER_LXD_NAME=""

#######################
# basic section begin #
#######################

name() {
    if [ -z "$1" ]; then
        System.die "Container name can not be null!"
    fi
    BASHERT_CONTAINER_LXD_NAME="$1"
}

get_name() {
    has_name
    ret "$BASHERT_CONTAINER_LXD_NAME"
}


has_name() {
    if [ -z "$BASHERT_CONTAINER_LXD_NAME" ]; then
        System.die "Set container name first!"
    fi
}

is_exist() {
    has_name
    if [ -n "`lxc list -c n --format csv $BASHERT_CONTAINER_LXD_NAME`" ]; then
        return 0
    fi
    return 1
}

# get_state => RUNNING/STOPPED
get_state() {
    has_name
    local state
    state=`lxc list -c s --format csv $BASHERT_CONTAINER_LXD_NAME`
    ret "$state"
}

sync_task() {
    while [ -n "`lxc operation list | grep TASK`" ]; do
        sleep 1
    done
}

start() {
    var state="`get_state`"
    if [[ "$state" == "STOPPED" ]]; then
        lxc start $BASHERT_CONTAINER_LXD_NAME
        sync_task
    fi
}

stop() {
    var state="`get_state`"
    if [[ "$state" == "RUNNING" ]]; then
        lxc $BASHERT_CONTAINER_LXD_NAME
        sync_task
    fi
}

restart() {
    var state="`get_state`"
    if [[ "$state" == "RUNNING" ]]; then
        lxc restart $BASHERT_CONTAINER_LXD_NAME
    elif [[ "$state" == "STOPPED" ]]; then
        lxc start $BASHERT_CONTAINER_LXD_NAME
    fi
    sync_task
}

be_god() {
    has_name

    set_config "raw.lxc" \
        "lxc.apparmor.profile = unconfined" \
        "lxc.mount.auto = proc:rw sys:rw cgroup:rw" \
        "lxc.cgroup.devices.allow = a" \
        "lxc.cap.drop ="

    set_config "security.nesting" "true"
    set_config "security.privileged" "true"
}

#####################
# basic section end #
#####################


############################
# lxd config section begin #
############################

# set_config key val
# set_config key val1 val2
set_config() {
    has_name
    local key_name="$1"
    local result
    shift
    echo -n "`IFS=$'\n'; echo "$*"`" | lxc config set $BASHERT_CONTAINER_LXD_NAME "$key_name" -
}

# get_config abc
get_config() {
    has_name
    local value
    value="`lxc config get $BASHERT_CONTAINER_LXD_NAME "$1"`"
    ret "$value"
}

##########################
# lxd config section end #
##########################


############################
# lxd device section begin #
############################

is_device_exist() {
    has_name
    if [ -n "`lxc config device list $BASHERT_CONTAINER_LXD_NAME | grep "^$1$"`" ]; then
        return 0
    fi
    return 1
}

is_mount_disk() {
    has_name

    local file_path
    file_path="`File.get_absolute_path "$1"`"

    if [ -n "`lxc config device show $BASHERT_CONTAINER_LXD_NAME | grep -Eo "^\s*source: $file_path\$"`" ]; then
        return 0;
    fi
    return 1
}

find_mount_disk() {
    has_name

    for i in `lxc config device list $BASHERT_CONTAINER_LXD_NAME`; do
        if [[ "`lxc config device get $BASHERT_CONTAINER_LXD_NAME "$i" source`" == "$1" ]]; then
            ret "$i"
        fi
    done
    System.die "Can not find $1 is mounted in the container!"
}

mount_disk() {
    :
}

umount_disk() {
    :
}

##########################
# lxd device section end #
##########################


##########################
# lxd exec section begin #
##########################

exec_command() {
    lxc exec $BASHERT_CONTAINER_LXD_NAME -- sh -c "$@"
}

########################
# lxd exec section end #
########################
