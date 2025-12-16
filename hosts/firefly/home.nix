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
        "DP-8,highres,auto,auto"
        "DP-9,highres,auto,auto"

        "HDMI-A-1,highres,0x0,auto"
        "DP-2,highres,auto,auto"
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
