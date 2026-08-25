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

The service performs ZFS operations as root. Its SSH request runs as the `kubex` user
and needs a dedicated key plus a verified Nixberry host key.

### Configure unattended ZFS key retrieval

Generate a dedicated key on Kubex.

```bash
sudo install -d -m 0700 -o kubex -g users /var/lib/kubex-zfs-unlock
sudo -u kubex ssh-keygen -t ed25519 \
  -f /var/lib/kubex-zfs-unlock/id_ed25519 \
  -N '' \
  -C 'kubex-zfs-unlock'
sudo cat /var/lib/kubex-zfs-unlock/id_ed25519.pub
```

Add the resulting public key to Nixberry's `rap` account in
`hosts/nixberry/default.nix`:

```nix
users.users.rap.openssh.authorizedKeys.keys = [
  "ssh-ed25519 <KUBEX_ZFS_UNLOCK_PUBLIC_KEY> kubex-zfs-unlock"
];
```

On the Nixberry console, obtain its Ed25519 host public key and verify its
fingerprint through a trusted channel. Do not trust a key obtained only through
`ssh-keyscan`.

```bash
sudo cat /etc/ssh/ssh_host_ed25519_key.pub
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Declare the verified key in `hosts/kubex/default.nix` so strict host-key checking is
available to the boot-time service:

```nix
programs.ssh.knownHosts.nixberry = {
  hostNames = [ "nixberry" ];
  publicKey = "ssh-ed25519 <NIXBERRY_ED25519_HOST_PUBLIC_KEY>";
};
```

Configure `wait-for-zfs-pool.service` in `modules/nixos/roles/k3s/zfs.nix` to pass
the dedicated key explicitly when it runs SSH as `kubex`:

```nix
if key="$(${pkgs.util-linux}/bin/runuser -u ${config.hostConfig.user.name} -- ${pkgs.openssh}/bin/ssh \
  -i /var/lib/kubex-zfs-unlock/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o BatchMode=yes \
  -o ConnectTimeout=10 \
  -o StrictHostKeyChecking=yes \
  "$key_source" ulock-agent get)"; then
  # ...
fi
```

Rebuild Nixberry first to authorize the key, then rebuild Kubex. Before restarting
the unit, verify the non-interactive request manually:

```bash
sudo -u kubex ssh \
  -i /var/lib/kubex-zfs-unlock/id_ed25519 \
  -o IdentitiesOnly=yes \
  -o StrictHostKeyChecking=yes \
  rap@nixberry ulock-agent get
```

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
