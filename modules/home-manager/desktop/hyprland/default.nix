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
    hyprpaper = mkEnableOption "Enable hyprpaper desktop wallpaper manager";
    hyprcursor = mkEnableOption "Enable hyprcursor theme";
    configOnly = mkEnableOption "Only write hyprland config with home-manager";
    monitors = mkOption {
      type = with types; listOf attrs;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    catppuccin.hyprland.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      package =
        if cfg.configOnly
        then null
        else pkgs.hyprland;
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

    # Make nix-path available for all tools
    xdg.configFile."environment.d/envvars.conf".text = ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';
  };
}
