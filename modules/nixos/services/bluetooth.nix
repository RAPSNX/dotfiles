{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.services.bluetooth;
in
{
  options.hostConfig.services.bluetooth = lib.mkEnableOption "Enable bluetooth features.";

  config = lib.mkIf cfg {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
