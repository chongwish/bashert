# Bashert

Bash script for my work & my life with Seashell 2.

## Package List

- [CommandLine](man/CommandLine.md)
- Container
  - [Lxd](man/Container/Lxd.md)
  - [Nspawn](man/Container/Nspawn.md)
  - Docker
- VirtualMachine
  - Kvm
- DevelopmentTool
  - Git
- Media
  - Video
  - Music
  - Photo
- FileSystem
- Application
  - Portable
  - Appimage
  - Snap
  - Flatpak
- File
- Service
  - Xorg
  - Pulseaudio
  - Systemd
- Distribution
  - ArchLinux
    - PackageManager
    - Installation
    - Configuration
  - Gentoo
    - PackageManager
    - Installation
    - Configuration

## My life & work script

### Desktop application in lxd

You need a host user can use the xorg server that host machine had.

```bash
export LXDG_USER=$(whoami)
```

Create a desktop container:

```bash
lxcg-launch debian/11 debian-11
```

Just like the original lxd command: `lxc launch debian/11 desktop-11`.

Run a X11 application:

```bash
lxcg-exec debian-11 firefox
```

Just like the original lxd command: `lxc exec debian-11 firefox`

If you already has a container, you can make it a to be a desktop container:

```bash
lxcg-init debian-11
```

For nvidia user, please make sure you have installed "nvidia-container-toolkit" && "libnvidia-container" and them can work by root:

```bash
lxcg-nvidia-container debian-11
```

### Share file in lxd

Just like the `mount` & `umount` command, we can share the current directory to container:

```bash
lxc-temp-mount
```

We also can mount some directory we want to:

```bash
lxc-temp-mount Documents/Share
```

And we can go to the directory in the container we mount:

```bash
lxc-temp-cd Documents/Share
```

We umount them if them are useless:

```bash
lxc-temp-umount Document/Share
```

### Create a lxd image

Create a old version distribution that is not existed in lxd remote store (Now only debian 5 & 6):

```bash
lxc-create-image $container debian/5
```

### Desktop application in systemd-nspawn

Unlike "Desktop application in lxd", You need a container which could be run x11 application first! The script `systemdg-run` only do a little work which can't be easy finish without code, for example, the socket binding.

```bash
systemdg-run -M debian-11 firefox
```

The nvidia device in `/dev` will be only existed when you have started xorg server in your host machine, we can't bind that as your container is enabled by the `systemctl`. So we can bind that when we have had a xorg server, and execute a x11 container application in your nvidia machine:

```bash
systemdg-run --machine debian-11 --nvidia firefox
```

### Refresh my script

When a common namespace modified, you want to regenerate all your script, you can do it below:

```bash
refresh-seashellized-script ~/Projects/ShellScript/Bashert/bin ~/.bin
```

### Backup file in my nas

Copy file to my data hdd with progress.

```bash
nas-copy downloads_path /mnt/Data/Videos/target_path
nas-copy downloads_path_2 /mnt/Data/Videos/target_path_2
```

Sync file to my backup disk with pregress.

```bash
nas-sync
```