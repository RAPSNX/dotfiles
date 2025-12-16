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
