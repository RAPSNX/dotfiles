{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.roles.desktop;

  tuigreetTheme = lib.concatStringsSep ";" [
    "container=black"
    "text=white"
    "border=magenta"
    "title=magenta"
    "greet=cyan"
    "prompt=blue"
    "input=magenta"
    "time=green"
    "action=yellow"
    "button=red"
  ];

  tuigreetCommand = lib.escapeShellArgs [
    "${pkgs.tuigreet}/bin/tuigreet"
    "--sessions"
    "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
    "--session-wrapper"
    "${config.services.displayManager.sessionData.wrapper}"
    "--time"
    "--remember"
    "--remember-user-session"
    "--asterisks"
    "--theme"
    tuigreetTheme
  ];
in
{
  config = lib.mkIf cfg {
    boot.plymouth.enable = true;

    console = {
      font = "ter-v32n";
      packages = [ pkgs.terminus_font ];
    };

    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "mauve";

      cursors.enable = true;
      plymouth.enable = true;
      tty.enable = true;
    };

    programs.hyprland = {
      enable = true;
      withUWSM = false;
    };

    programs.niri.enable = true;

    services.greetd = {
      enable = true;
      useTextGreeter = true;

      settings = {
        terminal.vt = 1;

        default_session = {
          command = tuigreetCommand;
          user = "greeter";
        };
      };
    };
  };
}
