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

        workspaces = ''
          workspace=1, monitor:DP-1, default:true
          workspace=2, monitor:DP-1
          workspace=3, monitor:DP-1
          workspace=4, monitor:DP-2, default:true
          workspace=5, monitor:DP-2
          workspace=6, monitor:DP-2
        '';
      };
    };

    desktop.niri = {
      enable = true;
    };
  };
}
