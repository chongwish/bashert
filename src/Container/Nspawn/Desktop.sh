
BASHERT_CONTAINER_NSPAWN_DESKTOP_UID="`id -u`"

run() {
    # Don't use $XAUTHORITY here
    if [ -z "`xhost | grep localuser:$(whoami)`" ]; then
        xhost +local:
    fi

    create_socket_pulse
    create_socket_dbus

    local desktop_env
    var container_name="`Container.Nspawn.get_name`"

    Container.Nspawn.exec_command "[ -e /run/user/BASHERT_CONTAINER_NSPAWN_DESKTOP_UID ] || systemctl start user@$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID"

    # ENV DISPLAY
    local display_env=${DISPLAY:-":0.0"}
    desktop_env="$desktop_env DISPLAY=${display_env}"

    # ENV PULSE
    desktop_env="$desktop_env PULSE_SERVER=\$HOME/.pulse-native"
    
    # ENV DBUS
    desktop_env="$desktop_env DBUS_SESSION_BUS_ADDRESS=unix:path=\$HOME/.bus"

    # ENV XDG
    desktop_env="$desktop_env XDG_RUNTIME_DIR=/run/user/$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID"

    machinectl shell -q --uid="$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID" "$container_name" /bin/sh -lc "$desktop_env $@"
}

create_socket_dbus() {
    local container_user_home
    local socket_path
    container_user_home="`machinectl shell -q --uid="$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID" "$container_name" /bin/sh -lc 'echo -n "$HOME"'`"
    socket_path="$container_user_home/.bus"

    if ! `Container.Nspawn.is_mounted "$socket_path"`; then
        var container_name="`Container.Nspawn.get_name`"
        machinectl bind --mkdir "$container_name" "/run/user/$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID/bus" "$socket_path"
    fi
}

create_socket_pulse() {
    local container_user_home
    local socket_path
    container_user_home="`machinectl shell -q --uid="$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID" "$container_name" /bin/sh -lc 'echo -n "$HOME"'`"
    socket_path="$container_user_home/.pulse-native"

    if ! `Container.Nspawn.is_mounted "$socket_path"`; then
        var container_name="`Container.Nspawn.get_name`"
        machinectl bind --mkdir "$container_name" "/run/user/$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID/pulse/native" "$socket_path"
    fi
}
