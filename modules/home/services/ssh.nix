{ config, ... }:
let
  sensitiveSshDir = "${config.home.homeDirectory}/Nextcloud/Home/Sensitive/.ssh";
  linkFromSensitiveSsh = config.lib.file.mkOutOfStoreSymlink;
in
{
  services.ssh-agent.enable = true;

  home.file = {
    ".ssh/config".source = linkFromSensitiveSsh "${sensitiveSshDir}/config";
    ".ssh/swiss".source = linkFromSensitiveSsh "${sensitiveSshDir}/swiss";
    ".ssh/swiss.pub".source = linkFromSensitiveSsh "${sensitiveSshDir}/swiss.pub";
    ".ssh/yubi".source = linkFromSensitiveSsh "${sensitiveSshDir}/yubi";
    ".ssh/yubi.pub".source = linkFromSensitiveSsh "${sensitiveSshDir}/yubi.pub";
  };
}
