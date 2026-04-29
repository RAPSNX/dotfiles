{
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.hyprland.hypridle;
in
{
  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = cfg.cmd;
        };
        listener = [
          # autolock
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          # display off
          {
            timeout = 3600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
