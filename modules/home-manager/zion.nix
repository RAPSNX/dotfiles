{lib, ...}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  roles = {
    workdevice = false;

    desktop = {
      hyprland = {
        enable = true;
        hyprlock = true;
      };
    };
  };

  home = {
    username = "rap";
    homeDirectory = lib.mkDefault "/home/rap";
    stateVersion = lib.mkDefault "22.05";
  };
}
