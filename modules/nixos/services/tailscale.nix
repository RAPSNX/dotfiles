{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.services.tailscale;
in
{
  options.hostConfig.services.tailscale = lib.mkEnableOption "Enable tailscaled.";

  config = lib.mkIf cfg {
    services.tailscale.enable = true;
  };
}
