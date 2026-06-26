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
  };
}
