
bind_dev() {
    var container_name="`Container.Nspawn.get_name`"

    for i in "/dev/nvidia0" "/dev/nvidiactl" "/dev/nvidia-modeset"; do
        if ! `Container.Nspawn.is_mounted "$i"`; then
            machinectl bind --mkdir "$container_name" "$i"
        fi
    done
}

bind() {
    System.Nvidia.make_uvm_dev
    
    var container_name="`Container.Nspawn.get_name`"

    for i in `get_dev_list` `get_lib64_list` `get_lib32_list` `get_config_list`; do
        local from="${i%%:*}"
	    local to="${i#*:}"
        machinectl bind --mkdir "$container_name" "$from" "$to"
    done
}

get_lib64_list() {
    ldconfig -p | grep -Ei '(nvidia|libnv|libcuda)' | grep " /usr/lib64/" | awk -F '=> ' '{print $2}' | sed -E 's|(/usr/lib64/(.*))|\1:/usr/lib/x86_64-linux-gnu/\2|g'
}

get_lib32_list() {
    ldconfig -p | grep -Ei '(nvidia|libnv|libcuda)' | grep " /usr/lib/" | awk -F '=> ' '{print $2}' | sed -E 's|(/usr/lib/(.*))|\1:/usr/lib/i386-linux-gnu/\2|g'
}

get_dev_list() {
    echo '/dev/nvidia0:/dev/nvidia0'
    echo '/dev/nvidiactl:/dev/nvidiactl'
    echo '/dev/nvidia-modeset:/dev/nvidia-modeset'
    echo '/dev/nvidia-uvm:/dev/nvidia-uvm'
    echo '/dev/nvidia-caps:/dev/nvidia-caps'
    echo '/dev/nvidia-uvm-tools:/dev/nvidia-uvm-tools'
}

get_config_list() {
    echo '/usr/bin/nvidia-bug-report.sh:/usr/bin/nvidia-bug-report.sh'
    echo '/opt/bin/nvidia-cuda-mps-control:/usr/bin/nvidia-cuda-mps-control'
    echo '/opt/bin/nvidia-cuda-mps-server:/usr/bin/nvidia-cuda-mps-server'
    echo '/opt/bin/nvidia-debugdump:/usr/bin/nvidia-debugdump'
    echo '/usr/bin/nvidia-modprobe:/usr/bin/nvidia-modprobe'
    echo '/opt/bin/nvidia-ngx-updater:/usr/bin/nvidia-ngx-updater'
    echo '/usr/bin/nvidia-sleep.sh:/usr/bin/nvidia-sleep.sh'
    echo '/opt/bin/nvidia-smi:/usr/bin/nvidia-smi'
    echo '/usr/bin/nvidia-xconfig:/usr/bin/nvidia-xconfig'
    echo '/etc/modprobe.d/nvidia.conf:/usr/lib/x86_64-linux-gnu/modprobe.d/nvidia-utils.conf'
    echo '/usr/lib64/xorg/modules/drivers/nvidia_drv.so:/usr/lib/x86_64-linux-gnu/xorg/modules/drivers/nvidia_drv.so'
    echo '/usr/share/X11/xorg.conf.d/nvidia-drm-outputclass.conf:/usr/share/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf'
    echo '/usr/share/egl/egl_external_platform.d/15_nvidia_gbm.json:/usr/share/egl/egl_external_platform.d/15_nvidia_gbm.json'
    echo '/usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json'
    echo '/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/nvidia_icd.json'
    echo '/usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/usr/share/vulkan/implicit_layer.d/nvidia_layers.json'
}

get_bind_list() {
    for i in `get_dev_list` `get_lib64_list` `get_lib32_list` `get_config_list`; do
        echo "--bind=$i \\"
    done
}
