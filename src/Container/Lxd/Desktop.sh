
BASHERT_CONTAINER_LXD_DESKTOP_UID=""
BASHERT_CONTAINER_LXD_DESKTOP_GID=""

use Container.Lxd [ has_name set_config ]

owner() {
    if [ -z "$1" ]; then
        System.die "Username can not be null"
    fi
    BASHERT_CONTAINER_LXD_DESKTOP_UID="`id -u "$1"`"
    BASHERT_CONTAINER_LXD_DESKTOP_GID="`id -g "$1"`"
}

init() {
    has_name

    #Container.Lxd.be_god
    map_id
    Container.Lxd.restart
    create_user
    grant_user
    create_device_gpu
    create_socket_xorg
    create_socket_pulse
    create_socket_dbus
}

run() {
    # Don't use $XAUTHORITY here
    if [ -z "`xhost | grep localuser:$(whoami)`" ]; then
        xhost +local:
    fi
    local desktop_env
    var container_name="`Container.Lxd.get_name`"

    Container.Lxd.exec_command "[ -e /run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID ] || systemctl start user@$BASHERT_CONTAINER_LXD_DESKTOP_UID"
    #recreate_runtime_socket_pulse
    #recreate_runtime_socket_dbus

    # ENV DISPLAY
    local display_env=${DISPLAY:-":0.0"}
    desktop_env="$desktop_env DISPLAY=${display_env}"

    # ENV PULSE
    desktop_env="$desktop_env PULSE_SERVER=\$HOME/.pulse-native"
    #desktop_env="$desktop_env PULSE_SERVER=unix:path=/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/pulse/native"

    # ENV DBUS
    desktop_env="$desktop_env DBUS_SESSION_BUS_ADDRESS=unix:path=\$HOME/.bus"
    #desktop_env="$desktop_env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/bus"

    # ENV XDG
    desktop_env="$desktop_env XDG_RUNTIME_DIR=/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID"

    lxc exec "$container_name" -- sh -c '[ -f "/etc/pulse/client.conf" ] && sed -i "s/; enable-shm = yes/enable-shm = no/g" /etc/pulse/client.conf'
    lxc exec "$container_name" -- su - `id -nu $BASHERT_CONTAINER_LXD_DESKTOP_UID` -c "$desktop_env $1"
}

map_id() {
    set_config "raw.idmap" "both $BASHERT_CONTAINER_LXD_DESKTOP_UID $BASHERT_CONTAINER_LXD_DESKTOP_GID"
}

create_user() {
    local container_user="`Container.Lxd.exec_command "grep ':x:$BASHERT_CONTAINER_LXD_DESKTOP_UID' /etc/passwd | awk -F ':' '{print \\$1}'"`"

    if [ -z "$container_user" ]; then
        Container.Lxd.exec_command "useradd -m -u $BASHERT_CONTAINER_LXD_DESKTOP_UID `id -nu $BASHERT_CONTAINER_LXD_DESKTOP_UID`"
    else
        if ! [[ "$container_user" == "`id -nu $BASHERT_CONTAINER_LXD_DESKTOP_UID`" ]]; then
            System.die "Uid: $BASHERT_CONTAINER_LXD_DESKTOP_UID has been exist!"
        fi
    fi
}

grant_user() {
    local video_line
    local audio_line
    video_line=`grep video /etc/group | awk -F':' '{print $1":"$2":"$3}'`
    audio_line=`grep audio /etc/group | awk -F':' '{print $1":"$2":"$3}'`
    Container.Lxd.exec_command "sed -ri 's/^(video|audio)/# \1/' /etc/group"
    Container.Lxd.exec_command "echo '$video_line' >> /etc/group"
    Container.Lxd.exec_command "echo '$audio_line' >> /etc/group"
    Container.Lxd.exec_command "gpasswd -a `id -nu $BASHERT_CONTAINER_LXD_DESKTOP_UID` video"
    Container.Lxd.exec_command "gpasswd -a `id -nu $BASHERT_CONTAINER_LXD_DESKTOP_UID` audio"
}

################
# device begin #
################

create_device_gpu() {
    local device_name="device-gpu"

    if ! `Container.Lxd.is_device_exist $device_name`; then
        var container_name="`Container.Lxd.get_name`"
        lxc config device add "$container_name" \
            $device_name \
            gpu \
            uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
            gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID
    fi
}

create_socket_xorg() {
    local device_name="socket-xorg"

    if ! `Container.Lxd.is_device_exist $device_name`; then
        var container_name="`Container.Lxd.get_name`"
        lxc config device add "$container_name" \
            $device_name \
            proxy \
            bind=container \
            security.uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
            security.gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
            connect=unix:@/tmp/.X11-unix/X0 \
            listen=unix:@/tmp/.X11-unix/X0
    fi
}

create_socket_pulse() {
    local device_name="socket-pulse"

    if ! `Container.Lxd.is_device_exist $device_name`; then
        var container_name="`Container.Lxd.get_name`"
        lxc config device add "$container_name" \
            $device_name \
            proxy \
            bind=container \
            uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
            gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
            security.uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
            security.gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
            mode="0777" \
            connect=unix:/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/pulse/native \
            listen=unix:/home/`id -nu $BASHERT_CONTAINER_LXD_DESKTOP_UID`/.pulse-native
    fi
}

create_socket_dbus() {
    local device_name="socket-dbus"

    if ! `Container.Lxd.is_device_exist $device_name`; then
        var container_name="`Container.Lxd.get_name`"
        lxc config device add "$container_name" \
            $device_name \
            proxy \
            bind=container \
            uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
            gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
            security.uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
            security.gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
            mode="0777" \
            connect=unix:/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/bus \
            listen=unix:/home/`id -nu $BASHERT_CONTAINER_LXD_DESKTOP_UID`/.bus
    fi
}

# @discarded
create_runtime_socket_pulse() {
    var container_name="`Container.Lxd.get_name`"
    local pulse_name="runtime-socket-pulse"

    Container.Lxd.exec_command "su - `id -nu $BASHERT_CONTAINER_LXD_DESKTOP_UID` -c 'mkdir /run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/pulse'"

    lxc config device add "$container_name" \
        $pulse_name \
        proxy \
        bind=container \
        uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
        gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
        security.uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
        security.gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
        mode="0777" \
        connect=unix:/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/pulse/native \
        listen=unix:/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/pulse/native
}

# @discarded
recreate_runtime_socket_pulse() {
    var container_name="`Container.Lxd.get_name`"
    local pulse_name="runtime-socket-pulse"

    if [ -n "`lxc config device list $container_name | grep "^$pulse_name$"`" ]; then
        if [ -n "`Container.Lxd.exec_command "[ -e /run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID ] || echo 1"`" ]; then
            lxc config device remove $container_name $pulse_name
            Container.Lxd.exec_command "systemctl start user@$BASHERT_CONTAINER_LXD_DESKTOP_UID"
            create_runtime_socket_pulse
        fi
    else
        Container.Lxd.exec_command "[ -e /run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID ] || systemctl start user@$BASHERT_CONTAINER_LXD_DESKTOP_UID"
        create_runtime_socket_pulse
    fi
}

# @discarded
create_runtime_socket_dbus() {
    var container_name="`Container.Lxd.get_name`"
    local dbus_name="runtime-socket-dbus"

    lxc config device add "$container_name" \
        $dbus_name \
        proxy \
        bind=container \
        uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
        gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
        security.uid=$BASHERT_CONTAINER_LXD_DESKTOP_UID \
        security.gid=$BASHERT_CONTAINER_LXD_DESKTOP_GID \
        mode="0777" \
        connect=unix:/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/bus \
        listen=unix:/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID/bus
}

# @discarded
recreate_runtime_socket_dbus() {
    var container_name="`Container.Lxd.get_name`"
    local dbus_name="runtime-socket-dbus"

    if [ -n "`lxc config device list $container_name | grep "^$dbus_name$"`" ]; then
        if [ -n "`Container.Lxd.exec_command "[ -e /run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID ] || echo 1"`" ]; then
            lxc config device remove $container_name $dbus_name
            Container.Lxd.exec_command "systemctl start user@$BASHERT_CONTAINER_LXD_DESKTOP_UID"
            create_runtime_socket_dbus
        fi
    else
        Container.Lxd.exec_command "[ -e /run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID ] || systemctl start user@$BASHERT_CONTAINER_LXD_DESKTOP_UID"
        create_runtime_socket_dbus
    fi
}

# @discarded
create_disk_xdg() {
    var container_name="`Container.Lxd.get_name`"
    local xdg_name="disk-xdg"
    lxc config device add $container_name \
        $xdg_name \
        disk \
        readonly=true \
        source=/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID \
        path=/run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID
}

# @discarded
recreate_disk_xdg() {
    var container_name="`Container.Lxd.get_name`"
    local xdg_name="disk-xdg"
    if [ -n "`lxc config device list $container_name | grep "^$xdg_name$"`" ]; then
        if [ -n "`Container.Lxd.exec_command "[ -e /run/user/$BASHERT_CONTAINER_LXD_DESKTOP_UID ] || echo 1"`" ]; then
            lxc config device remove $container_name $xdg_name
            create_disk_xdg
        fi
    else
        create_disk_xdg
    fi
}

##############
# device end #
##############
