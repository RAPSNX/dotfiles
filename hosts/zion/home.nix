{
  lib,
  pkgs,
  config,
  ...
}:
{
  home = {
    username = "rap";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
  };

  roles = {
    work = false;
    email = "mail@rapsn.me";

    desktop = {
      noctalia = {
        enable = true;
        windowsReboot.enable = true;
      };

      hyprland = {
        enable = true;
        package = pkgs.hyprland;
        autostart = [
          "firefox"
          "ddcutil --display 2 setvcp 60 0x09" # Focus secondary display
        ];
      };
    };
  };
}
