{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.services.podman;
in
{
  options.hostConfig.services.podman = lib.mkEnableOption "Enable podman containerization engine:";

  config = lib.mkIf cfg {
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
