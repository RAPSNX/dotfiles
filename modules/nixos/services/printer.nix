{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.services.printing;
in {
  options.hostConfiguration.services.printing = mkEnableOption "Enable printing service.";

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
