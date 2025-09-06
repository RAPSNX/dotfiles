{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.roles.desktop;
in {
  config = mkIf cfg {
    nixpkgs.config.joypixels.acceptLicense = true;
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;
      packages = with pkgs; [
        nerd-fonts.caskaydia-cove
        joypixels
      ];

      fontconfig = {
        antialias = true;
        enable = true;
        hinting = {
          autohint = true;
          enable = true;
          style = "slight";
        };
        subpixel = {
          rgba = "rgb";
          lcdfilter = "light";
        };
        defaultFonts = {
          emoji = ["Joypixels"];
        };
      };
    };
  };
}
