
use Container.Lxd [ has_name restart set_config get_config ]

init() {
    has_name

    check_environment

    map_video_gid
    restart

    add_nvidia_component
    restart
}

check_environment() {
    # 1 /dev/nvidia* must be exist
    # 2 nvidia-container-toolkit && libnvidia-container must be installed
    # 3 nvidia-container-cli must be ran with root (/usr/share/lxc/hooks/nvidia) or /dev/nvidia* is 666
    :
}

map_video_gid() {
    local video_gid
    local map_row
    video_gid=`grep ^video /etc/group | awk -F':' '{print $3}'`
    map_row="gid $video_gid $video_gid"

    var config="`get_config "raw.idmap"`"
    if [[ -z "$config" ]]; then
        set_config "raw.idmap" "$map_row"
    else
        set_config "raw.idmap" "$config" "$map_row"
    fi
}

add_nvidia_component() {
    set_config "nvidia.runtime" "true"
    set_config "nvidia.driver.capabilities" "all"
}