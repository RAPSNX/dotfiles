{ lib, ... }:
{
  imports = [
    ./env.nix
    ./boot.nix
    ./user.nix
    ./locale.nix
    ./starship.nix
    ./zsh.nix
  ];

  catppuccin = {
    enable = lib.mkDefault true;
    autoEnable = lib.mkDefault false;
  };
}
