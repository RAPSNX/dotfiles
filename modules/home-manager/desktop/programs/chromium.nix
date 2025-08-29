{
  pkgs,
  config,
  ...
}: let
  inherit (config.roles) useNixGL;
in {
  programs.chromium = {
    enable = true;
    package =
      if useNixGL
      then config.lib.nixGL.wrap pkgs.chromium
      else pkgs.chromium;
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--enable-wayland-ime"
    ];
  };
}
