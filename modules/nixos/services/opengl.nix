{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hostConfig.services.opengl;
in
{
  options.hostConfig.services.opengl = mkEnableOption "Enable opengl features.";

  config = mkIf cfg {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [ mesa ];
      };
    };
  };
}
