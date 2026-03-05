{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.hostConfig.services.tailscale;
in
{
  options.hostConfig.services.tailscale = mkEnableOption "Enable tailscaled.";

  config = mkIf cfg {
    services.tailscale.enable = true;
  };
}
