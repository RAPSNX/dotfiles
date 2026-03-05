{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko

    ./hardware-configuration.nix
    ./disko.nix
  ];

  hostConfig = {
    boot = {
      enable = true;
      supportedFilesystems = [ "zfs" ];
    };

    user = {
      name = "kubex";
      initialHashedPassword = "$y$j9T$8uQSJbY6w9kjXnj74JKjA1$pWYgNf.gb497suX//oIw6aggEPoD2Xv1kvMKZfDTOU/";
      keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKX8MmA9KdHCny6rKCGZlyd/J5qCXh+YDM0/3ZGDmfyaAAAABHNzaDo= yubi@rapsn.me"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqKYXW07z0llbDKRIakLD1PjHe3HxK9iu6czXs+ZU7v techkey@rapsn"
      ];
      extraOptions = { };
      extraGroups = [ ];
    };

    roles = {
      k3s = true;
    };
    services = {
      sops = true;
    };
  };

  sops.secrets.ssh_config = {
    sopsFile = ./secrets.yaml;
    path = "/home/kubex/.ssh/config";
    mode = "600";
    owner = "kubex";
  };

  networking = {
    hostName = "kubex";
    hostId = "5851308f"; # Required by zfs
  };

  environment = {
    variables = {
      PROMPT = "%m@%n> ";
      RPROMPT = "%D %T";
    };
    systemPackages = [ pkgs.restic ];
  };

  nix.settings.trusted-users = [ "@wheel" ]; # need for remote build
}
