# Nspawn

Set container name:

```bash
Container.Nspawn.name "my-name"
```

Check if the path is mounted by other thing

```bash
Container.Nspawn.is_mounted "container-path"
```

Execute a command without path (Nspawn need a full path command)

```bash
Container.Nspawn.exec_command "ls /"
```

## Desktop

Run the desktop application:

```bash
Container.Nspawn.Desktop.run "firefox"
```

### Nvidia

Bind the nvidia device:

```
Container.Nspawn.bind_dev
```