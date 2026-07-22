{
  lib,
  pkgs,
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
  #
  # Built as a real script (not an inline multi-line string) because
  # services.swayidle.timeouts[].command is embedded verbatim into a
  # systemd unit file's ExecStart= line -- a raw multi-line value there
  # breaks systemd's unit-file parser (each embedded newline starts a new,
  # invalid "key=value" line) unless every line ends with a `\` line
  # continuation. A script path avoids that entirely.
  dpmsToggle = pkgs.writeShellScript "dpms-toggle" ''
    set -euo pipefail
    state="''${1:?missing state (on|off)}"
    if pgrep -x sway >/dev/null; then
      swaymsg output '*' dpms "$state"
    elif pgrep -x niri >/dev/null; then
      case "$state" in
        off) niri msg action power-off-monitors ;;
        on) niri msg action power-on-monitors ;;
      esac
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
          command = "${dpmsToggle} off";
          resumeCommand = "${dpmsToggle} on";
        }
      ];

      events.lock = lockCmd;
    };
  };
}
