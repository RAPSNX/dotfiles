{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./common

    ./cli
    ./desktop
  ];

  config = {
    roles = {
      workdevice = true;

      useNixGL = true;

      desktop.hyprland = {
        enable = true;
        configOnly = true;
      };
      autostart = [
        # Programs
        "[ workspace special:scratchy silent ] ${(config.lib.nixGL.wrap pkgs.alacritty)}/bin/alacritty -t scratchy"
        "[ workspace special:aux silent ] /opt/zscaler/scripts/zstray_desktop.sh"

        "systemd-run --user --unit voice mumble"
        "systemd-run --user --unit secrets keepassxc"
        "systemd-run --user --unit google chromium"

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
