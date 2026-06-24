{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.roles.desktop;
in
{
  config = lib.mkIf cfg {
    boot.plymouth = {
      enable = true;
    };

    programs.hyprland = {
      enable = true;
      withUWSM = false;
    };

    catppuccin = {
      enable = true;
      flavor = "macchiato";
    };

    programs.niri.enable = true;

    services.greetd = {
      enable = true;

      settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
    };
  };
}
