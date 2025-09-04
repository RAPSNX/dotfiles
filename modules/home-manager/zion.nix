{lib, ...}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  config = {
    roles = {
      workdevice = false;

      desktop = {
        hyprland = {
          enable = true;
          hyprlock = true;
        };
      };
    };
    # hm config
    home = rec {
      username = "rap";
      homeDirectory = lib.mkDefault "/home/${username}";
      stateVersion = lib.mkDefault "22.05";
    };
  };
}
