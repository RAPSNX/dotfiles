{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.services.printing;
in
{
  options.hostConfig.services.printing = lib.mkEnableOption "Enable printing service.";

  config = lib.mkIf cfg {
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
