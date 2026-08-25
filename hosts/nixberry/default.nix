{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
  ];

  boot.kernelPackages = pkgs.linuxPackages;

  # Host specific configuration
  hostConfig = {
    environment.enableNeonixMini = false;

    user = {
      name = "rap";
      initialHashedPassword = "$y$j9T$8uQSJbY6w9kjXnj74JKjA1$pWYgNf.gb497suX//oIw6aggEPoD2Xv1kvMKZfDTOU/";
      extraOptions = { };
      extraGroups = [ ];
    };

    boot.enable = false;

    services = {
      nh = false;
      ssh = true;
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
