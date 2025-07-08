{lib, ...}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  # NOTE: Additionally
  # - Create window-rules
  # - Check dotfiles structure
  # - Move most of nixOS to HM

  config = {
    # my hm-modules config
    roles = {
      workdevice = true;

      useNixGL = true;

      desktop = {
        hyprland = {
          enable = true;
          configOnly = true;
          hyprlock = false;
          hyprpaper = false;
          monitors = [
            {
              ID = "HDMI-A-1";
              settings = "2560x1440@144, 0x0, 1";
            }
            {
              ID = "DP-1";
              settings = "3840x2160@240, 2560x0, 1.5";
            }
            {
              ID = "eDP-1";
              settings = "disabled";
            }
          ];
        };
      };
    };
    # hm config
    home = {
      username = "raphael.groemmer@stackit.cloud";
      homeDirectory = lib.mkDefault "/home/Raphael.Groemmer@stackit.cloud";
      stateVersion = lib.mkDefault "22.05";
    };
  };
}
