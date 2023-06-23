
bind_dev() {
    var container_name="`Container.Nspawn.get_name`"

    for i in "/dev/nvidia0" "/dev/nvidiactl" "/dev/nvidia-modeset"; do
        if ! `Container.Nspawn.is_mounted "$i"`; then
            machinectl bind --mkdir "$container_name" "$i"
        fi
    done
}

get_bind_lib64_list() {
    ldconfig -p | grep -Ei '(nvidia|libcuda)' | grep "lib64/" | awk -F '=> ' '{print $2}' | sed -E 's|(/usr/lib64/(.*))|--bind=\1:/usr/lib/x86_64-linux-gnu/\2 \\|g'
}

get_bind_lib32_list() {
    ldconfig -p | grep -Ei '(nvidia|libcuda)' | grep "lib/" | awk -F '=> ' '{print $2}' | sed -E 's|(/usr/lib/(.*))|--bind=\1:/usr/lib/i386-linux-gnu/\2 \\|g'
}

get_bind_dev_list() {
    echo -e '--bind=/dev/nvidia0 \\\n--bind=/dev/nvidiactl \\\n--bind=/dev/nvidia-modeset \\'
}

get_bind_config_list() {
    echo '--bind=/usr/bin/nvidia-bug-report.sh:/usr/bin/nvidia-bug-report.sh \'
    echo '--bind=/opt/bin/nvidia-cuda-mps-control:/usr/bin/nvidia-cuda-mps-control \'
    echo '--bind=/opt/bin/nvidia-cuda-mps-server:/usr/bin/nvidia-cuda-mps-server \'
    echo '--bind=/opt/bin/nvidia-debugdump:/usr/bin/nvidia-debugdump \'
    echo '--bind=/usr/bin/nvidia-modprobe:/usr/bin/nvidia-modprobe \'
    echo '--bind=/opt/bin/nvidia-ngx-updater:/usr/bin/nvidia-ngx-updater \'
    echo '--bind=/opt/bin/nvidia-powerd:/usr/bin/nvidia-powerd \'
    echo '--bind=/usr/bin/nvidia-sleep.sh:/usr/bin/nvidia-sleep.sh \'
    echo '--bind=/opt/bin/nvidia-smi:/usr/bin/nvidia-smi \'
    echo '--bind=/usr/bin/nvidia-xconfig:/usr/bin/nvidia-xconfig \'
    echo '--bind=/etc/modprobe.d/nvidia.conf:/usr/lib/x86_64-linux-gnu/modprobe.d/nvidia-utils.conf \'
    echo '--bind=/usr/lib64/xorg/modules/drivers/nvidia_drv.so:/usr/lib/x86_64-linux-gnu/xorg/modules/drivers/nvidia_drv.so \'
    echo '--bind=/usr/share/X11/xorg.conf.d/nvidia-drm-outputclass.conf:/usr/share/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf \'
    echo '--bind=/usr/share/egl/egl_external_platform.d/15_nvidia_gbm.json:/usr/share/egl/egl_external_platform.d/15_nvidia_gbm.json \'
    echo '--bind=/usr/share/glvnd/egl_vendor.d/10_nvidia.json:/usr/share/glvnd/egl_vendor.d/10_nvidia.json \'
    echo '--bind=/usr/share/vulkan/icd.d/nvidia_icd.json:/usr/share/vulkan/icd.d/nvidia_icd.json \'
    echo '--bind=/usr/share/vulkan/implicit_layer.d/nvidia_layers.json:/usr/share/vulkan/implicit_layer.d/nvidia_layers.json \'
}