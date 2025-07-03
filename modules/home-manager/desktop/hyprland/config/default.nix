{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.roles.desktop.hyprland;
in {
  imports = [
    ./keybindings.nix
    # ./windowrules.nix
  ];

  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 8;
      gaps_out = 10;
      border_size = 3;
    };

    windowrule = [
      "float, class:steam"
      "size 70% 70%, class:steam"
      "center, class:steam"

      "float, class:com.nextcloud.desktopclient.nextcloud"
      "size 20% 50%, class:com.nextcloud.desktopclient.nextcloud"
      "move 79% 3%, class:com.nextcloud.desktopclient.nextcloud"
    ];

    input = {
      kb_layout = "eu";
      repeat_rate = 35;
      repeat_delay = 250;
      accel_profile = "flat";
      sensitivity = 1; # -1.0 - 1.0, 0 means no modification.
    };

    exec-once = [
      # move alacritty to special workspace silently
      "sleep 1 && [ workspace special silent ] alacritty -t scratchy"
      "${pkgs.firefox}/bin/firefox"
      "${pkgs.blueman}/bin/blueman-applet"
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

      # work
      "/opt/zscaler/scripts/zstray_desktop.sh"
      "teams-for-linux"

      # set wallpapers randomly
      "sleep 1 && /home/rap/.nix-profile/bin/shuffle-wallpaper"
    ];

    monitors =
      lib.map
      (m: "${m.ID}, ${m.settings}")
      cfg.monitors;

    workspace = with lib; let
      # NOTE: Possible nil-pointer if elemAt access null object
      primary = (elemAt cfg.monitors 1).ID;
      secondary = (elemAt cfg.monitors 0).ID;
    in [
      "name:1, monitor:${primary}"
      "name:2, monitor:${primary}"
      "name:3, monitor:${primary}"
      "name:4, monitor:${primary}"
      "name:5, monitor:${secondary}"
      "name:6, monitor:${secondary}"
      "name:7, monitor:${secondary}"
      "name:8, monitor:${secondary}"
      "name:9, monitor:${secondary}"
    ];

    dwindle = {
      preserve_split = "yes";
      special_scale_factor = 0.8;
    };

    decoration = {
      blur = {
        enabled = true;
        size = 3;
        passes = 2;
        ignore_opacity = true;
        new_optimizations = true;
      };
      rounding = 5;
      active_opacity = 0.98;
      inactive_opacity = 0.85;
    };
  };
}
