{pkgs, ...}: {
  services = {
    nextcloud-client.enable = true;
  };

  home.packages = [
    pkgs.nextcloud-client
  ];
}
