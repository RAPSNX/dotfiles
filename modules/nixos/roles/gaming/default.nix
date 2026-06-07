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
          extraPkgs = p: lib.attrValues {
            inherit (p)
              gamemode
              mangohud # Fps widget ingame
              ;
          };
        };
        gamescopeSession.enable = true;
        # Compatiblility tools accessable for steam
        extraCompatPackages = lib.attrValues {
          inherit (pkgs) proton-ge-bin;
        };
      };
    };

    environment.systemPackages = lib.attrValues {
      inherit (pkgs)
        adwsteamgtk # Gnome theme for steam
        winetricks # DLL libary collection
        ;
      inherit (pkgs.wineWowPackages) waylandFull; # OpenSouce implementation of WinAPI
    };
  };
}
