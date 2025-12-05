{lib, ...}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  config = {
    roles = {
      workdevice = true;

      desktop.hyprland = {
        enable = true;
        hyprlock = true;
        configOnly = true;
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
  };
}
