{
  lib,
  mylib,
  config,
  ...
}:
with lib;
with mylib;
let
  cfg = config.roles.desktop.hyprland;
in
{
  options.roles.desktop.hyprland.monitor = with types; mkOpt (listOf str) "Monitor config as list.";

  config = {
    wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
      inherit (cfg) monitor;
    };
  };
}
