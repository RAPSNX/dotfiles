{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with lib;
with mylib;
let
  cfg = config.roles.desktop.hyprland;
in
{
  imports = [
    # Addons
    ./addons/hyprpaper.nix
    ./addons/hyprlock.nix
    ./addons/hypridle.nix

    # Settings
    ./settings/autostart.nix
    ./settings/binds.nix
    ./settings/global.nix
    ./settings/monitor.nix
    ./settings/windows.nix
    ./settings/workspaces.nix

    # Module options
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    catppuccin.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      inherit (cfg) package;

      systemd.enable = false; # Disable for uswm
    };

    home.packages = with pkgs; [
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
      extraPortals = with pkgs; [
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
