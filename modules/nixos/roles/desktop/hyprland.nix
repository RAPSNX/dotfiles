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
    };

    security.sudo.extraRules = [
      {
        users = [ "greeter" ];

        commands = [
          {
            command = lib.getExe rebootWindows;
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    services.greetd = {
      enable = true;
      settings.terminal.vt = 1;
    };
  };
}
