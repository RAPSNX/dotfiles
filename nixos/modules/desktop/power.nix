{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.system.modules.desktop;
in {
  config = mkIf cfg {
    powerManagement.enable = false;
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
    };
  };
}
