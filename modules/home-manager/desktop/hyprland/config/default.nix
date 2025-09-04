{
  pkgs,
  lib,
  config,
  ...
}: let
  # TODO: remove
  cfg = config.roles.desktop.hyprland;
in {
  imports = [
    ./keybindings.nix
    ./windowrules.nix
  ];

  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    general = {
      gaps_in = 8;
      gaps_out = 10;
      border_size = 3;
    };

    xwayland = {
      force_zero_scaling = true;
    };

    input = {
      kb_layout = "eu";
      repeat_rate = 35;
      repeat_delay = 200;
      accel_profile = "flat";
      sensitivity = 1; # -1.0 - 1.0, 0 means no modification.
    };

    exec-once = let
      # Dirty workaround because hyprland & waybar need some time to get ready
      delay = s: list: map (exe: "sleep ${toString s} && ${exe}") list;
    in
      lib.concatLists [
        # move alacritty to special workspace silently
        [
          "[ workspace special:scratchy silent ] ${(config.lib.nixGL.wrap pkgs.alacritty)}/bin/alacritty -t scratchy"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        ]

        (delay 1 [
          "${config.home.homeDirectory}/.nix-profile/bin/shuffle-wallpaper"
          "firefox"
        ])

        # (delay 2 config.roles.autostart)
      ];

    source = [
      "~/.config/hypr/monitors.conf"
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
