{ lib, ... }:
{
  catppuccin = {
    enable = lib.mkDefault true;
    autoEnable = lib.mkDefault false;
  };
}
