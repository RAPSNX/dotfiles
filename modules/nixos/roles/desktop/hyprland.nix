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

  rebootWindows = pkgs.writeShellScript "reboot-windows" ''
    exec ${lib.getExe' pkgs.systemd "systemctl"} reboot \
      --boot-loader-entry=auto-windows
  '';

  tuigreetCommand = lib.escapeShellArgs [
    "${pkgs.tuigreet}/bin/tuigreet"

    "--sessions"
    "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"

    "--session-wrapper"
    "${config.services.displayManager.sessionData.wrapper}"

    "--power-reboot"
    "/run/wrappers/bin/sudo ${rebootWindows}"

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
      autoEnable = true;
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

    security.sudo.extraRules = [
      {
        users = [ "greeter" ];

        commands = [
          {
            command = "${rebootWindows}";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

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
