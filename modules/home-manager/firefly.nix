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
        hyprlock = true;
        configOnly = true;
      };
      autostart = [
        # Programs
        "[ workspace special:scratchy silent ] ${(config.lib.nixGL.wrap pkgs.alacritty)}/bin/alacritty -t scratchy"

        "systemd-run --user --unit voice mumble --tray"
        "systemd-run --user --unit secrets keepassxc"

        # Autoclose
        "sleep 1 && killall /usr/bin/intune-portal"

        # Unfocus last workspace
        "sleep 1 && hyprctl dispatch workspace 1"
      ];
    };

    home = {
      username = "rapsn";
      homeDirectory = lib.mkDefault "/home/rapsn";
      stateVersion = lib.mkDefault "22.05";
      activation = {
        mirror-hyprland-config = lib.hm.dag.entryAfter ["writeBoundary"] ''
          DIR="$HOME/.config/hypr"
          sed -e 's#/hypr/monitors#/hypr/monitors-work#g' \
          -e 's#/hypr/workspaces#/hypr/workspaces-work#g' "$DIR/hyprland.conf" > "$DIR/hyprland-work.conf"
        '';
      };
    };
  };
}
