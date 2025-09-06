{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.services.bluetooth;
in {
  options.hostConfiguration.services.bluetooth = mkEnableOption "Enable bluetooth features.";

  config = mkIf cfg {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
