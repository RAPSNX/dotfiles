{
  lib,
  config,
  ...
}: let
  cfg = config.roles.desktop.hyprland;
in {
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    general = {
      gaps_in = 8;
      gaps_out = 10;
      border_size = 3;
    };

    # Auto tile new windows
    dwindle = {
      preserve_split = "yes";
      special_scale_factor = 0.8;
    };

    input = {
      kb_layout = "eu";
      repeat_rate = 45;
      repeat_delay = 150;
      accel_profile = "flat";
      sensitivity = 1; # -1.0 - 1.0, 0 means no modification.
    };

    xwayland = {
      force_zero_scaling = true;
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
