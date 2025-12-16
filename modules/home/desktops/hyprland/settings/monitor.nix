{
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      monitor = [
        "DP-8,highres,auto,auto"
        "DP-9,highres,auto,auto"

        "DP-2,highres,0x0,auto"
        "DP-1,highres,auto,auto"
      ];
    };
  };
}
