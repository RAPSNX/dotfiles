{lib, ...}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  # TODO:
  # --
  # - Check what needs to be configurable (diff zion)
  # - Create window-rules
  # - Move most of nixOS to HM
  # - Use atuin

  # FIXME:
  # - Bluetooth tray not working
  # - Check why nixpath in nixshell is at very fist shadowing the nix-shell path

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
          monitors = [
            {
              ID = "HDMI-A-1";
              settings = "2560x1440@144, 0x0, 1";
            }
            {
              ID = "DP-1";
              settings = "3840x2160@240, 2560x0, 1.25";
            }
            {
              ID = "eDP-1";
              settings = "highres, 5632x0, 1";
            }
          ];
        };
      };
      autostart = [
        "[ workspace special:aux silent ] /opt/zscaler/scripts/zstray_desktop.sh"
        "mumble"
        "killall /opt/microsoft/intune/bin/intune-portal"
        "sleep 1 && hyprctl dispatch workspace 1"
      ];
    };
    # hm config
    home = {
      username = "raphael.groemmer@stackit.cloud";
      homeDirectory = lib.mkDefault "/home/Raphael.Groemmer@stackit.cloud";
      stateVersion = lib.mkDefault "22.05";
    };
  };
}
