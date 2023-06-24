
make_uvm_dev() {
    if [ ! -e "/dev/nvidia-uvm" ]; then
        nvidia-modprobe -uc 0
    fi
}