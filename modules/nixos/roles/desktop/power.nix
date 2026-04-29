{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.roles.desktop;
in
{
  config = lib.mkIf cfg {
    powerManagement.enable = false;
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
    };
  };
}
