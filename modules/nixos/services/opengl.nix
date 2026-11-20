{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.services.opengl;
in
{
  options.hostConfig.services.opengl = lib.mkEnableOption "Enable opengl features.";

  config = lib.mkIf cfg {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}
