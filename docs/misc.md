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
