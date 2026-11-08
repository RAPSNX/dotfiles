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
    nixpkgs.config.joypixels.acceptLicense = true;
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;
      packages = builtins.attrValues {
        inherit (pkgs) joypixels;
        inherit (pkgs.nerd-fonts) caskaydia-cove fira-code jetbrains-mono;
      };

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
          emoji = [ "Joypixels" ];
        };
      };
    };
  };
}
