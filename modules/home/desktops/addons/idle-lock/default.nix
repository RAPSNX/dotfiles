{
  lib,
  config,
  ...
}:
let
  enabled = config.roles.desktop.sway.enable || config.roles.desktop.niri.enable;

  # Sway and niri both need swayidle/swaylock (compositor-agnostic wlr-protocol
  # tools despite the name), but each needs a different DPMS command. Both
  # compositors can be enabled at once (as separate selectable sessions), so
  # this detects which one is actually running rather than being duplicated
  # per-compositor, which would double up the swayidle timeout list.
  dpms = state: ''
    if pgrep -x sway >/dev/null; then
      swaymsg output '*' dpms ${state}
    elif pgrep -x niri >/dev/null; then
      niri msg action power-${if state == "off" then "off" else "on"}-monitors
    fi
  '';

  lockCmd = "${config.programs.swaylock.package}/bin/swaylock -f";
in
{
  config = lib.mkIf enabled {
    catppuccin.swaylock.enable = false;

    programs.swaylock = {
      enable = true;
      settings = {
        color = "1e1e2e";
        indicator = true;
        indicator-radius = 100;
        indicator-thickness = 10;
        inside-color = "5b6078";
        ring-color = "cad3f5";
        line-color = "00000000";
        separator-color = "00000000";
        key-hl-color = "a6da95";
        bs-hl-color = "ed8796";
        ignore-empty-password = true;
      };
    };

    services.swayidle = {
      enable = true;
      systemdTargets = [
        "sway-session.target"
        "graphical-session.target"
      ];

      timeouts = [
        {
          timeout = 300;
          command = lockCmd;
        }
        {
          timeout = 3600;
          command = dpms "off";
          resumeCommand = dpms "on";
        }
      ];

      events.lock = lockCmd;
    };
  };
}
