{
  lib,
  config,
  ...
}:
lib.mkIf (config.hostConfig.user.name != "root") {
  sops = {
    age = {
      generateKey = false;
      keyFile = "/home/${config.hostConfig.user.name}/.config/sops/age/keys.txt";
    };

    defaultSopsFile = ../../../secrets/common/ssh.yaml;

    secrets = {
      ssh_config = {
        path = "/home/${config.hostConfig.user.name}/.ssh/config";
        owner = config.hostConfig.user.name;
        mode = "0600";
      };

      swiss = {
        path = "/home/${config.hostConfig.user.name}/.ssh/swiss";
        owner = config.hostConfig.user.name;
        mode = "0600";
      };

      "swiss.pub" = {
        path = "/home/${config.hostConfig.user.name}/.ssh/swiss.pub";
        owner = config.hostConfig.user.name;
        mode = "0644";
      };

      yubi = {
        path = "/home/${config.hostConfig.user.name}/.ssh/yubi";
        owner = config.hostConfig.user.name;
        mode = "0600";
      };

      "yubi.pub" = {
        path = "/home/${config.hostConfig.user.name}/.ssh/yubi.pub";
        owner = config.hostConfig.user.name;
        mode = "0644";
      };
    };
  };
}
