{config, ...}: {
  services.ssh-agent.enable = true;

  sops.secrets.ssh_config = {
    sopsFile = ../secrets.yaml;
    path = "${config.home.homeDirectory}/.ssh/config";
    mode = "600";
  };
}
