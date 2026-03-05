{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.hostConfig.services.podman;
in
{
  options.hostConfig.services.podman = mkEnableOption "Enable podman containerization engine:";

  config = mkIf cfg {
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
