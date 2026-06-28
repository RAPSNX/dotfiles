{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.services.bluetooth;
in
{
  options.hostConfig.services.bluetooth = lib.mkEnableOption "Enable Bluetooth support.";

  config = lib.mkIf cfg {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
