{
  lib,
  config,
  pkgs,
  ...
}:
{
  roles = {
    work = true;
    email = "raphael.groemmer@stackit.cloud";

    desktop.hyprland = {
      enable = true;
      package = null;

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
        "1,monitor:DP-2,default:true"
        "2,monitor:DP-2"
        "3,monitor:DP-2"
        "4,monitor:HDMI-A-1,default:true"
        "5,monitor:HDMI-A-1"
        "6,monitor:HDMI-A-1"
        "7,monitor:eDP-1"
      ];

      extraConfig = ''
        monitor=eDP-1,prefer,auto,1

        bindl = , switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, prefer,auto, 1"
        bindl = , switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"

        exec-once = sleep 5 && uwsm app -- mumble --tray
        exec-once = sleep 5 && hyprctl dispatch closewindow class:ZSTray
      '';

      hyprlock.enable = false;
      hypridle = {
        enable = true;
        cmd = "${config.home.homeDirectory}/Projects/swaywm/swaylock/build/swaylock";
      };
    };
  };

  home.packages = with pkgs; [
    # CLIs
    mypkgs.gardenctl
    mypkgs.gardenlogin
    stackit-cli
    openstackclient-full
    vault-bin

    # Tools(inputs.import-tree.match ".*/default\\.nix" ./modules/home)
    brightnessctl
  ];

  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };

  home = {
    username = "rapsn";
    homeDirectory = lib.mkDefault "/home/rapsn";
    stateVersion = lib.mkDefault "22.05";
  };
}
