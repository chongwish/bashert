
bind_dev() {
    var container_name="`Container.Nspawn.get_name`"

    for i in "/dev/nvidia0" "/dev/nvidiactl" "/dev/nvidia-modeset"; do
        if ! `Container.Nspawn.is_mounted "$i"`; then
            machinectl bind --mkdir "$container_name" "$i"
        fi
    done
}

get_bind_lib_list() {
    ldconfig -p | grep -Ei '(nvidia|libcuda)' | awk -F '=> ' '{print $2}' | sed -E 's|(/usr/lib64/(.*))|bind=\1:/usr/lib/x86_64-linux-gnu/\2 \\|g'
}