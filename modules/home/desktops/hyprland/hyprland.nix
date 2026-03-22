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
    };

    home.packages = [
      hyprland-qtutils
      slurp
    ];

    # systemd.user = {
    #   enable = true;
    #   # This could be removed if https://github.com/nix-community/home-manager/pull/8541 gets merged
    #   # Inside xdg.portal they do exactly the same thing, that is: packages = [ pkgs.xdg-desktop-portal ] ++ config.xdg.portal.extraPortals;
    #   # and this MR just adds systemd.user.packages = packages;
    #   packages = [
    #     pkgs.xdg-desktop-portal
    #     pkgs.xdg-desktop-portal-wlr
    #   ];
    # };
    # #
    # xdg.portal = {
    #   enable = true;
    #   extraPortals = with pkgs; [
    #     xdg-desktop-portal-hyprland
    #     xdg-desktop-portal-wlr
    #   ];
    #   config.common = {
    #     default = [
    #       "wlr"
    #     ];
    #   };
    # };

    # environment.d defines environment variables for the user session, beyond shell level.
    # It is processed by `systemd --user`, basically after login.
    xdg.configFile."environment.d/envvars.conf".text = ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';
  };
}
