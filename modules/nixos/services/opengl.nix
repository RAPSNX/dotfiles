{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.services.opengl;
in {
  options.hostConfiguration.services.opengl = mkEnableOption "Enable opengl features.";

  config = mkIf cfg {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [mesa];
      };
    };
  };
}
