# Setup new host

Create host directory with `hardware-configuration.nix` & `default.nix`, configuring NixOS modules via the `system`
option.

## Sops-nix

In order to access secrets via `sops-nix`, this repo uses an `age` identity file by default. For a YubiKey-backed
setup, point the host at an `age-plugin-yubikey` identity file instead.

This repo keeps the SSH-related secrets in `secrets/common/ssh.yaml` and deploys them into `~/.ssh/`:

- NixOS hosts get them from `modules/nixos/system/sops.nix`
- standalone Home Manager hosts get them from `modules/home/services/sops.nix`
- hybrid hosts should let only one layer own `~/.ssh` to avoid duplicate files

```
# Install the tools needed for a YubiKey-backed age identity.
services.pcscd.enable = true;
environment.systemPackages = with pkgs; [
  age
  age-plugin-yubikey
];

# Generate a YubiKey identity and use it in the host config.
age-plugin-yubikey --generate \
  --name swiss \
  --slot 82 \
  --pin-policy once \
  --touch-policy cached \
  > ~/.config/sops/age/yubikey-identity.txt

# The corresponding recipient can then be added to `.sops.yaml`.
age-plugin-yubikey --list
```

## Github action

There are Github Actions, to check and build every host against a `PR`.
For each new host there needs to be config for the pipeline.

# TODO(docs): Add sops-nix docs, add & edit secrets

# TODO(docs): Add workdevice manual steps, ppa hyprland and uwsm
