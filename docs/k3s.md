# K3S

## Prerequistes

For initial bootstrap of the single `K3S` cluster, a `NixOS` device reachable over `SSH` is prerequiste.
To prevent incorrect `cluster-init`, set `system.k3s.enable = false` to install the host.

After reboot the server in the correct location, enable the `k3s` module and remote rebuild.

```bash
nixos-rebuild switch --flake .#kubex --target-host kubex@192.168.55.10 --use-remote-sudo
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

The `k3s` role includes a `wait-for-zfs-pool.service` unit that imports `kubex-main`
if needed, then loads its encryption key from `rap@nixberry` before `k3s.service`
starts.

Because the unit runs non-interactively, `kubex` is configured for passwordless sudo
for members of the `wheel` group.

## Copy kubeconfig

```bash
scp kubex@192.168.55.10:.kube/config .config/kubeconfig/homelab.yaml
sed -i s/127.0.0.1:6443/api.k3s.rapsn.me:6443/g ~/.config/kubeconfig/homelab.yaml
```

## Copy ssh-key to kubex for remote backup to storagebox

// TODO

## Bootstrap flux

```bash

```

## Restart a node
In order to restart a node successfully, after the `node` is rebooted, execute the following in order to import all encrypted zfs-pools.

```bash
# Import pool automatically
sudo zpool import -a

# Load encryption key, will promt for password
sudo zfs load-key kubex-main
```
