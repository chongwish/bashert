# @todo
die() {
    echo "$@" > /dev/tty
    exit 1
}
