{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.hostConfig.services.printing;
in
{
  options.hostConfig.services.printing = mkEnableOption "Enable printing service.";

  config = mkIf cfg {
    services = {
      printing.enable = true;

      avahi = {
        enable = true;
        nssmdns4 = true;

        openFirewall = true;
      };
    };
  };
}
