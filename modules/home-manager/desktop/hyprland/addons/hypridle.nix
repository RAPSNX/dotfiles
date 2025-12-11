{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.roles.desktop.hyprland.hypridle;
in {
  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = cfg.cmd;
        };
        listener = [
          # autolock
          {
            timeout = 1200;
            on-timeout = "hyprlock";
          }
          # display off
          {
            timeout = 9000;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
