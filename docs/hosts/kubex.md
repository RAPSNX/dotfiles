# K3S

## Prerequistes

For initial bootstrap of the single `K3S` cluster, a `NixOS` device reachable over `SSH` is prerequiste.
To prevent incorrect `cluster-init`, set `system.k3s.enable = false` to install the host.

After reboot the server in the correct location, enable the `k3s` module and remote rebuild.

```bash
nixos-rebuild switch --flake .#kubex --target-host '<KUBEX_SSH_TARGET>' --use-remote-sudo
```

## ZFS Configuration

ZFS pool spreads over four SSDs, and is manually created with some fine-tune.

```bash
# ⚠️  This is disruptive!
sudo zpool create -f \
    -O encryption=on \
    -O keyformat=passphrase \
    -O keylocation=prompt \
    -O compression=lz4 \
    -O atime=off \
    -O mountpoint=none \
    -O xattr=sa \
    -O acltype=posixacl \
    -o ashift=12 \
    kubex-main \
    raidz2 /dev/sda /dev/sdb /dev/sdc /dev/sdd
```

The encrypted pool must be imported and unlocked before K3S starts.
After a reboot, unlock it manually using the recovery steps below. K3S waits
until the key is loaded, then starts automatically.

## Copy kubeconfig

```bash
scp '<KUBEX_SSH_TARGET>:.kube/config' ~/.config/kubeconfig/homelab.yaml
sed -i 's/127.0.0.1:6443/<K3S_API_ENDPOINT>:6443/g' ~/.config/kubeconfig/homelab.yaml
```

## Copy ssh-key to kubex for remote backup to storagebox

// TODO

## Bootstrap flux

```bash

```

## Manual recovery

Import the pool if necessary and enter its encryption passphrase when prompted:

```bash
sudo zpool list kubex-main >/dev/null 2>&1 || sudo zpool import -N kubex-main

sudo zfs load-key kubex-main
```
