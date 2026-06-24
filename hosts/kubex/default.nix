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
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1twcfSmy7xyUA5iWl51kfBHS1Dxpmmog0x55Z6HRNlAAAABHNzaDo= swiss"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKX8MmA9KdHCny6rKCGZlyd/J5qCXh+YDM0/3ZGDmfyaAAAABHNzaDo= yubi"
      ];
      extraOptions = { };
      extraGroups = [ ];
    };

    roles = {
      k3s = true;
    };
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
