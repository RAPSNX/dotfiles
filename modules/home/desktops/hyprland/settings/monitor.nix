{
  lib,
  mylib,
  config,
  ...
}:
with lib;
with mylib;
with types;
let
  cfg = config.roles.desktop.hyprland;
in
{
  options.roles.desktop.hyprland.monitors = mkOpt (listOf (submodule {
    options = {
      name = mkOpt str "Monitor identifier";
      width = mkOpt int "Width in pixel";
      hight = mkOpt int "Hight in pixel";
      hz = mkOpt str "Refresh rate";
      scale = mkOpt float "Scaling factor";
    };
  })) "List of Monitors that are configured in order starting from left to right";

  config = {
    wayland.windowManager.hyprland.settings = mkIf cfg.enable {
      monitor =
        (foldl'
          (acc: mon: {
            pos = builtins.floor (acc.pos + (mon.width / mon.scale));
            result = acc.result ++ [
              "desc:${mon.name},${toString mon.width}x${toString mon.hight},${toString acc.pos}x0,${toString mon.scale}"
            ];
          })
          {
            pos = 0;
            result = [ ];
          }
          cfg.monitors
        ).result;
    };
  };
}
