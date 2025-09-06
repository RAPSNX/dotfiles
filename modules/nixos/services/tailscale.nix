{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.services.tailscale;
in {
  options.hostConfiguration.services.tailscale = mkEnableOption "Enable tailscaled.";

  config = mkIf cfg {
    services.tailscale.enable = true;
  };
}
