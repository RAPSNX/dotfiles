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
      extraOptions = { };
      extraGroups = [ ];
    };

    roles = {
      k3s = true;
    };

    services.ssh = true;
  };

  networking = {
    hostName = "kubex";
    hostId = "5851308f"; # Required by zfs
  };

  boot.zfs.forceImportRoot = false;

  security = {
    sudo.wheelNeedsPassword = false;
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
