{lib, ...}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  # TODO:
  # - Check and diff work <-> private
  # - Switch on workdevice
  # - Tofi-drun should work...

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
# TODO: move to host config
# {work ? false}:
# if work
# then {
#   # Firefly
#   left = {
#     output = "HDMI-A-1";
#     settings = "2560x1440@144, 0x0, 1";
#   };
#   primary = {
#     output = "DP-1";
#     settings = "3840x2160@240, 2560x0, 1.5";
#   };
#   disable = {output = "eDP-1";};
# }
# else {
#   # Zion
#   left = {
#     output = "HDMI-A-1";
#     settings = "highres, 0x0, 1";
#   };
#   primary = {
#     output = "DP-1";
#     settings = "highres, 2560x0, 1.5";
#   };
#   disable = {output = "eDP-1";};
# }
# else {
#   # Zion
#   left = {
#     output = "DP-2";
#     settings = "2560x1440@240,highres, 0x0, 1";
#   };
#   primary = {
#     output = "DP-1";
#     settings = "3840x2160@240,highres, 2560x0, 1.5";
#   };
# }

