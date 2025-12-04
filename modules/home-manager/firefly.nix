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

      autostart = [
        # Programs
        "[ workspace special:scratchy silent ] alacritty -t scratchy"

        "systemd-run --user --unit voice mumble --tray"
        "systemd-run --user --unit secrets keepassxc"

        # Autoclose
        "sleep 1 && killall /usr/bin/intune-portal"

        # Unfocus last workspace
        "sleep 1 && hyprctl dispatch workspace 1"
      ];
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
