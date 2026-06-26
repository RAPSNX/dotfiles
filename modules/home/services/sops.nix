{
  lib,
  config,
  ...
}:
lib.mkIf (config ? targets && config.targets ? genericLinux && config.targets.genericLinux.enable) {
  sops = {
    age = {
      generateKey = true;
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };

    defaultSopsFile = ../../../secrets/common/ssh.yaml;

    secrets = {
      ssh_config = {
        path = "${config.home.homeDirectory}/.ssh/config";
        mode = "0600";
      };

      swiss = {
        path = "${config.home.homeDirectory}/.ssh/swiss";
        mode = "0600";
      };

      "swiss.pub" = {
        path = "${config.home.homeDirectory}/.ssh/swiss.pub";
        mode = "0644";
      };

      yubi = {
        path = "${config.home.homeDirectory}/.ssh/yubi";
        mode = "0600";
      };

      "yubi.pub" = {
        path = "${config.home.homeDirectory}/.ssh/yubi.pub";
        mode = "0644";
      };
    };
  };
}
