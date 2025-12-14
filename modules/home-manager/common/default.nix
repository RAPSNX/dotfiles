{
  lib,
  config,
  ...
}: {
  imports = [
    # global nix & nixpkgs settings
    ./options.nix
  ];

  programs.home-manager.enable = true;

  sops.secrets.ssh_config = {
    sopsFile = ./secrets.yaml;
    path = "${config.home.homeDirectory}/.ssh/config";
    mode = "600";
  };

  xdg.enable = true;

  news = {
    display = "silent";
    json = lib.mkForce {};
    entries = lib.mkForce [];
  };
}
