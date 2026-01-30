{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with lib;
with mylib;
with pkgs;
let
  cfg = config.roles.desktop.hyprland;
in
{
  options.roles.desktop.hyprland = {
    enable = mkEnableOption "Enable hyprland";

    package = mkPackageOption pkgs "hyprland" {
      nullable = true;
    };

    hyprlock = {
      enable = mkEnableOption "Enable hyprlock";
    };

    hypridle = {
      enable = mkEnableOption "Enable hypridle";
      cmd = mkOption { type = types.str; };
    };
  };

  config = lib.mkIf cfg.enable {
    catppuccin.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      inherit (cfg) package;

      plugins = with hyprlandPlugins; [
        hyprexpo
      ];

      systemd.enable = false; # Disable for uswm
    };

    home.packages = [
      hyprland-qtutils
      slurp
    ];

    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = [
            "hyprland"
            "gtk"
          ];
        };
      };
      extraPortals = [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-hyprland
      ];
    };

    # environment.d defines environment variables for the user session, beyond shell level.
    # It is processed by `systemd --user`, basically after login.
    xdg.configFile."environment.d/envvars.conf".text = ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';
  };
}
