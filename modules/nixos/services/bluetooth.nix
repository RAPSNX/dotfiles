{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.hostConfig.services.bluetooth;
in
{
  options.hostConfig.services.bluetooth = mkEnableOption "Enable bluetooth features.";

  config = mkIf cfg {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
