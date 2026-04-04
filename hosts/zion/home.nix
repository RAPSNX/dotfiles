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
      hyprland = {
        enable = true;
        package = pkgs.hyprland;

        hyprlock.enable = true;
        hypridle = {
          enable = true;
          cmd = "${pkgs.hyprlock}/bin/hyprlock";
        };
      };
    };

    desktop.niri = {
      enable = true;
    };
  };
}
