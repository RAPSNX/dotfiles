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

      monitor = [
        "eDP-1,highres,0x0,auto"

        # Home monitors
        "HDMI-A-1,highres,auto,auto"
        "DP-2,highres,auto,auto"
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
        bindl = , switch:off:Lid Switch,exec,hyprctl keyword monitor "eDP-1, 1920x1080@60, 0x0, 1"
        bindl = , switch:on:Lid Switch,exec,hyprctl keyword monitor "eDP-1, disable"
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
