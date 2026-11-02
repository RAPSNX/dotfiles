{ lib, ... }:
{
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  systemd.user.services.nextcloud-client.Service.ExecStop = lib.mkForce [ ];
}
