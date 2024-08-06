
BASHERT_CONTAINER_NSPAWN_DESKTOP_UID="`id -u`"

run() {
    local desktop_env=""
    local display_env=${DISPLAY:-":0.0"}
    local xdg_user_dir_path="/run/user/$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID"

    var container_name="`Container.Nspawn.get_name`"

    Container.Nspawn.exec_command "[ -e $xdg_user_dir_path ] || systemctl start user@$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID"

    # ENV XDG
    desktop_env="$desktop_env XDG_RUNTIME_DIR=$xdg_user_dir_path"

    # ENV PULSE
    desktop_env="$desktop_env PULSE_SERVER=$xdg_user_dir_path/pulse-native"
    
    # ENV DBUS
    desktop_env="$desktop_env DBUS_SESSION_BUS_ADDRESS=unix:path=$xdg_user_dir_path/bus"

    # ENV WAYLAND
    desktop_env="$desktop_env WAYLAND_DISPLAY=$WAYLAND_DISPLAY"

    # ENV DISPLAY
    desktop_env="$desktop_env DISPLAY=${display_env}"

    create_socket_wayland
    create_socket_pulse
    create_socket_dbus

    # Don't use $XAUTHORITY here
    if [ -z "`xhost | grep localuser:$(whoami)`" ]; then
        xhost +local:
    fi

    machinectl shell -q --uid="$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID" "$container_name" /bin/sh -lc "$desktop_env $@"
}

create_socket_wayland() {
    local container_user_home
    local socket_path
    local xdg_user_dir_path="/run/user/$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID"
    #container_user_home="`machinectl shell -q --uid="$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID" "$container_name" /bin/sh -lc 'echo -n "$HOME"'`"
    socket_path="$xdg_user_dir_path/$WAYLAND_DISPLAY"
    if ! `Container.Nspawn.is_mounted "$socket_path"`; then
        var container_name="`Container.Nspawn.get_name`"
        machinectl bind --mkdir "$container_name" "$socket_path" "$socket_path"
    fi
}

create_socket_dbus() {
    local container_user_home
    local socket_path
    local xdg_user_dir_path="/run/user/$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID"
    #container_user_home="`machinectl shell -q --uid="$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID" "$container_name" /bin/sh -lc 'echo -n "$HOME"'`"
    socket_path="$xdg_user_dir_path/bus"
    if ! `Container.Nspawn.is_mounted "$socket_path"`; then
        var container_name="`Container.Nspawn.get_name`"
        machinectl bind --mkdir "$container_name" "$socket_path" "$socket_path"
    fi
}

create_socket_pulse() {
    local container_user_home
    local socket_path
    local xdg_user_dir_path="/run/user/$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID"
    #container_user_home="`machinectl shell -q --uid="$BASHERT_CONTAINER_NSPAWN_DESKTOP_UID" "$container_name" /bin/sh -lc 'echo -n "$HOME"'`"
    socket_path="$xdg_user_dir_path/pulse-native"
    if ! `Container.Nspawn.is_mounted "$socket_path"`; then
        var container_name="`Container.Nspawn.get_name`"
        machinectl bind --mkdir "$container_name" "$xdg_user_dir_path/pulse/native" "$socket_path"
    fi
}
