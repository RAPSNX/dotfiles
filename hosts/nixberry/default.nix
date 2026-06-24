{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
  ];

  # Host specific configuration
  hostConfig = {
    user = {
      name = "rap";
      initialHashedPassword = "$y$j9T$8uQSJbY6w9kjXnj74JKjA1$pWYgNf.gb497suX//oIw6aggEPoD2Xv1kvMKZfDTOU/";
      keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1twcfSmy7xyUA5iWl51kfBHS1Dxpmmog0x55Z6HRNlAAAABHNzaDo= swiss"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKX8MmA9KdHCny6rKCGZlyd/J5qCXh+YDM0/3ZGDmfyaAAAABHNzaDo= yubi"
      ];
      extraOptions = { };
      extraGroups = [ ];
    };

    boot.enable = false;

    services = {
      tailscale = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = "nixberry";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  nix.settings.trusted-users = [ "@wheel" ]; # need for remote build

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
