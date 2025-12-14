{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  roles = {
    workdevice = false;

    desktop.hyprland = {
      enable = true;
      package = pkgs.hyprland;

      hyprlock.enable = true;
      hypridle = {
        enable = true;
        cmd = "hyprlock";
      };
    };
  };

  home = {
    username = "rap";
    homeDirectory = lib.mkDefault "/home/rap";
    stateVersion = lib.mkDefault "22.05";
  };
}
