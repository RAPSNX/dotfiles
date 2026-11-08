{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.roles.desktop;

  rebootWindows = pkgs.writeShellScriptBin "reboot-windows" ''
    exec ${lib.getExe' pkgs.systemd "systemctl"} reboot \
      --boot-loader-entry=auto-windows
  '';
in
{
  config = lib.mkIf cfg {
    boot.plymouth.enable = true;

    environment.systemPackages = [ rebootWindows ];

    console = {
      font = "ter-v32n";
      packages = [ pkgs.terminus_font ];
    };

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha";
      accent = "mauve";

      cursors.enable = true;
      plymouth.enable = true;
      tty.enable = true;
    };

    programs.hyprland = {
      enable = true;
      withUWSM = false;
      # Keep the cached build's optional UWSM support without enabling UWSM sessions.
      # The NixOS module otherwise rebuilds Hyprland with NO_UWSM enabled.
      package = pkgs.hyprland // {
        override = lib.setFunctionArgs (
          args: pkgs.hyprland.override (builtins.removeAttrs args [ "withUWSM" ])
        ) (lib.functionArgs pkgs.hyprland.override);
      };
    };

    security.sudo.extraRules = [
      {
        users = [ "greeter" ];

        commands = [
          {
            command = "/run/current-system/sw/bin/reboot-windows";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

  };
}
