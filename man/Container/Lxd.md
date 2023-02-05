# Lxd

Set container name:

```bash
Container.Lxd.name "my-name"
```

Sync lxd operation task:

```bash
Container.Lxd.sync_task
```

Make container to a supervisor container:

```bash
Container.Lxd.be_god
```

Set config:

```bash
Container.Lxd.set_config "key" "value1"
Container.Lxd.set_config "key" "value1" "value2"
```

Get config:

```bash
Container.Lxd.get_config "key"
```

Execute command:

```bash
Container.Lxd.execute_command "ls -al"
```

## Desktop

The host user who runs the desktop application:

```bash
Container.Lxd.Desktop.owner "chongwish"
```

Init a desktop container:

```bash
Container.Lxd.Desktop.init
```

Run a desktop application:

```bash
Container.Lxd.Desktop.run "firefox"
```

### Nvidia

Make a desktop container work well with nvidia driver:

```bash
Container.Lxd.Nvidia.init
```

## Kubernetes

## Container in lxd