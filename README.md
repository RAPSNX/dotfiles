<div align="center">
    <img width="128" src="./extra/img/snowflake.png"></img>

![NixOS](https://img.shields.io/badge/os-nixos-%2389dceb?style=for-the-badge&logo=nixos&logoColor=white)
![Hyprland](https://img.shields.io/badge/window_manager-hyprland-%23ffb29d?style=for-the-badge&logo=wayland&logoColor=white)
![Home Manager](https://img.shields.io/badge/package_manager-home_manager-%23f2cdcd?style=for-the-badge&logo=nixos&logoColor=white)
![Alacritty](https://img.shields.io/badge/terminal-alacritty-%23b4befe?style=for-the-badge&logo=alacritty&logoColor=white)
![Neovim](https://img.shields.io/badge/editor-neovim-%23f5e0dc?style=for-the-badge&color=a6e3a1&logo=neovim&logoColor=white)
![Love](https://img.shields.io/static/v1?logoColor=d8dee9&label=Built%20With&message=Love%20%E2%9D%A4%EF%B8%8F&color=cba6f7&style=for-the-badge)

<img width="512" src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png"></img>

This is my ever-evolving dotfiles repository, used to manage my desktop workstation, a MacBook Pro, and any Linux devbox capable of running Nix.
This repository is constantly improved or changed in some way.
It follows a structure to keep related configurations together, but not too much to reduce complexity.

</div>

## 🚀 Usage

### Bootstrap

```bash
# On fresh systems
nix develop

# NixOS rebuilds (hostname autodetection)
nh os switch .

# NixOS build with custom hostname
nh os build --hostname kubex .

# NixOS build installer iso image
nix build .#nixosConfigurations.vinox.config.system.build.isoImage

# NixOS remote switch
nixos-rebuild switch --flake .#kubex --target-host 192.168.55.10 --sudo

# HomeManager rebuilds (hostname & username autodetection)
nh home switch .

# HomeManager build with custom hostname
# TODO:!
```

<details>
    <summary>💽 Disko</summary>
<br>

Disko is used to provision disks, it creates automatically the `filsystems` configuration.

```bash
# Run disko from an installer
sudo nix run github:nix-community/disko --no-write-lock-file -- --mode zap_create_mount ./hosts/zion/disko.nix

# After this nixos can be installed
sudo nixos-install --flake .#zion
```

</details>

## Licenses

The NixOS logo used in this repository is based on the original design available at [NixOS Artwork Repository](https://github.com/NixOS/nixos-artwork/blob/master/logo/nix-snowflake-colours.svg).  
The original NixOS logo is licensed under the [Creative Commons Attribution-Share Alike 4.0 International License (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).  
This version of the logo has been modified, including changes to the colors, for use in this project.

As required by the CC BY-SA 4.0 license:
- Proper attribution must be given for the original logo design.
- Any further use, modification, or distribution of this logo (including the modified version) must comply with the terms of the CC BY-SA 4.0 license, including sharing derivative works under the same license.
