{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3

    ../../modules/nixos
  ];

  # Host specific configuration
  hostConfiguration = {
    stable = true;

    user = {
      name = "rap";
      initialHashedPassword = "$y$j9T$8uQSJbY6w9kjXnj74JKjA1$pWYgNf.gb497suX//oIw6aggEPoD2Xv1kvMKZfDTOU/";
      keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqKYXW07z0llbDKRIakLD1PjHe3HxK9iu6czXs+ZU7v techkey@rapsn"];
      extraOptions = {};
      extraGroups = [];
    };

    services = {
      tailscale = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
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

  environment.systemPackages = with pkgs; [neovim];

  nix.settings.trusted-users = ["@wheel"]; # need for remote build
}
