{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.services.opengl;
in
{
  options.hostConfig.services.opengl = lib.mkEnableOption "Enable OpenGL support.";

  config = lib.mkIf cfg {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = builtins.attrValues {
          inherit (pkgs) mesa;
        };
      };
    };
  };
}
