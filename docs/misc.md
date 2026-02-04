# Dual-boot
If reinstall / install `zion` or a workstation with dual-boot, follow this order:

1. Install `Windows` first, create the correct partitions while running the installer.
Ensure that the bootloader partition is big enough.
2. Next boot into `NixOS` live and install `NixOS` with the bootloader partition from windows.
// TODO: Add / Update this to use directly `nixos-install`?

# Dual-boot entry lost
When updating the `BIOS` the `nvram` gets cleared, resulting in a lost boot entry for `NixOS`.
This can not be fixed by simply boot into live-system and rebuild the bootloader like written in the public docs.
Follow this procedure to recreate the `nvram` boot-entry again:

1. Boot into `NixOS` live system using the `vinox` iso.
2. Mount and `chroot` into the main system.

```bash
sudo -i # Sudo is needed for every action

mount /dev/nvme0n1p{X} /mnt # mount root system
mount /dev/nvme0n1p{X} /mnt/boot # mount bootloader

nixos-enter
NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot # not sure if this is needed

sudo efibootmgr --create \
  --disk /dev/nvme0n1 \ # Disk not partition
  --part 1 \
  --label "NixOS" \
  --loader '\EFI\systemd\systemd-bootx64.efi' \ # Mind the backslashes
```

## UWSM (legacy not used anymore)

### start apps
Use `uswm app -- <app-name>` to start apps.
This will start the app in a seperate `systemd` scope, which is part of the `app.slice`.
If not, the process will be part of the `session.slice`, which can result in termination of the user session.

Keep the slice as clean as possible:
```bash
│   │ │ ├─wayland-wm@hyprland\x2duwsm.desktop.service
│   │ │ │ ├─77102 /run/current-system/sw/bin/Hyprland
│   │ │ │ └─77200 Xwayland :0 -rootless -core -listenfd 54 -listenfd 55 -displayfd 107 -wm 104
```

## Nix follows

```
    neonix = {
      url = "github:rgroemmer/neonix/plugin-enhancement";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

This will follow the actual flakes `nixpkgs`, neonix by itself uses `nixvim` from its own inputs, which is not part
of `nixpkgs`.
If the flakes `nixpkgs` is to new, plugins and packages from it will be "to new" for the rather outdated `nixvim` from neonix repo.
This can lead to problems starting nvim, this can be fixed by update the `neonix` flake accordingly.

> There is also a nix (lix?) bug, which does not update the `flake.lock` when a follows is removed.
