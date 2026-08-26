{
  lib,
  inputs,
  ...
}:
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"

    ./installer.nix
    ./diagnostics.nix
  ];

  # Host specific configuration
  hostConfig = {
    boot = {
      enable = true;
      supportedFilesystems = [ "ntfs" ];
    };

    user = {
      name = "root";
      initialHashedPassword = "";
      extraOptions = { };
      extraGroups = [ ];
    };

    services.ssh = true;
  };

  networking.hostName = "vinox";
  zramSwap.enable = true; # save RAM for VMs & small hosts

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
