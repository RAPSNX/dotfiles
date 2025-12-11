{
  lib,
  config,
  ...
}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  roles = {
    workdevice = true;

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
