{lib, ...}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  # TODO:
  # --
  # - Check what needs to be configurable (diff zion)
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
        };
      };
      autostart = [
        # Programs
        "[ workspace special:aux silent ] /opt/zscaler/scripts/zstray_desktop.sh"
        "mumble"
        "keepassxc"
        "sleep 2 && chromium"

        # Autoclose
        "killall /opt/microsoft/intune/bin/intune-portal"

        # Unfocus last workspace
        "sleep 1 && hyprctl dispatch workspace 1"
      ];
    };

    home = {
      username = "raphael.groemmer@stackit.cloud";
      homeDirectory = lib.mkDefault "/home/Raphael.Groemmer@stackit.cloud";
      stateVersion = lib.mkDefault "22.05";
    };
  };
}
