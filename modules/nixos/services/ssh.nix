{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.services.ssh;
in
{
  options.hostConfig.services.ssh = lib.mkEnableOption "OpenSSH server";

  config = lib.mkIf cfg {
    services.openssh = {
      enable = true;
      settings = {
        PubkeyAuthentication = true;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
  };
}
