{ lib, ... }:
{
  programs.swaylock = {
    enable = true;
    package = lib.mkDefault null;
  };

  catppuccin.swaylock.enable = true;
}
