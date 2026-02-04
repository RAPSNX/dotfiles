{
  lib,
  pkgs,
  ...
}:
{
  roles = {
    work = false;
    email = "mail@rapsn.me";

    desktop.hyprland = {
      enable = true;
      package = pkgs.hyprland;

      monitors = [
        # Monitor are automatically from left to right
        {
          name = "Samsung Electric Company LC27G7xT H4ZNC00167";
          width = 2560;
          hight = 1440;
          hz = "144.0";
          scale = 1.0;
        }
        {
          name = "Dell Inc. AW2725Q G2QC174";
          width = 3840;
          hight = 2160;
          hz = "143.99";
          scale = 1.5;
        }
      ];

      workspaces = [
        "1,monitor:DP-1,default:true"
        "2,monitor:DP-1"
        "3,monitor:DP-1"
        "4,monitor:DP-2,default:true"
        "5,monitor:DP-2"
        "6,monitor:DP-2"
        "7,monitor:eDP-1"
      ];

      extraConfig = "";

      hyprlock.enable = true;
      hypridle = {
        enable = true;
        cmd = "${pkgs.hyprlock}/bin/hyprlock";
      };
    };
  };

  home = {
    username = "rap";
    homeDirectory = lib.mkDefault "/home/rap";
    stateVersion = lib.mkDefault "22.05";
  };
}
