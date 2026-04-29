{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.roles.gaming;
in
{
  options.hostConfig.roles.gaming = lib.mkEnableOption "Enable NixOS gaming environment.";

  config = lib.mkIf cfg {
    services.ratbagd.enable = true; # Daemon to configure gaming mice, GUI piper comes through HM.

    programs = {
      gamemode.enable = true; # Performance increase through niceness while gaming.
      gamescope.enable = true; # Wayland steam-compositor
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraPkgs =
            p: with p; [
              mangohud # Fps widget ingame
              gamemode
            ];
        };
        gamescopeSession.enable = true;
        # Compatiblility tools accessable for steam
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      winetricks # DLL libary collection
      wineWowPackages.waylandFull # OpenSouce implementation of WinAPI
      adwsteamgtk # Gnome theme for steam
    ];
  };
}
