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
  hostConfiguration = {
    boot = {
      enable = true;
      supportedFilesystems = [ "ntfs" ];
    };

    user = {
      name = "root";
      initialHashedPassword = "";
      extraOptions = { };
      extraGroups = [ ];
      keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqKYXW07z0llbDKRIakLD1PjHe3HxK9iu6czXs+ZU7v" ];
    };
  };

  networking.hostName = "vinox";
  zramSwap.enable = true; # save RAM for VMs & small hosts

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
