{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.roles.desktop.hyprland;
in {
  imports = [
    # Config
    ./config

    # Addons
    ./addons/hyprpaper.nix
    ./addons/hyprlock.nix
  ];

  options.roles.desktop.hyprland = {
    enable = mkEnableOption "Enable hyprland";
    hyprlock = mkEnableOption "Enable hyprlock & hypridle";
  };

  config = mkIf cfg.enable {
    catppuccin.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      # TODO:(workdevice): Check if pkgs can still be set
      package = pkgs.hyprland;
      systemd.enable = false; # Disable for uswm
    };

    home.packages = with pkgs; [
      hyprland-qtutils
    ];

    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = ["hyprland" "gtk"];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    # environment.d defines environment variables for the user session, beyond shell level.
    # It is processed by `systemd --user`, basically after login.
    # - Adds the nix-store-path to the `PATH` globally for user applications.
    # - Adds XDG_DATA_DIRS globally to allign GTK themes and config dirs session wide.
    xdg.configFile."environment.d/envvars.conf".text = ''
      PATH="$HOME/.nix-profile/bin:$PATH"
      XDG_DATA_DIRS=${concatStringsSep ":" [
        "${config.home.homeDirectory}/.nix-profile/share"
        "/usr/share"
        "/nix/var/nix/profiles/default/share"
      ]}
    '';
  };
}
