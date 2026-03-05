{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.hostConfig.services.sops;
in
{
  options.hostConfig.services.sops = mkEnableOption "Enable tailscaled.";

  config = mkIf cfg {
    sops.age = {
      generateKey = true;
      keyFile = "/home/${config.hostConfig.user.name}/.config/sops/age/keys.txt";
    };
  };
}
