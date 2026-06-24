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
      keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1twcfSmy7xyUA5iWl51kfBHS1Dxpmmog0x55Z6HRNlAAAABHNzaDo= swiss"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKX8MmA9KdHCny6rKCGZlyd/J5qCXh+YDM0/3ZGDmfyaAAAABHNzaDo= yubi"
      ];
    };
  };

  networking.hostName = "vinox";
  zramSwap.enable = true; # save RAM for VMs & small hosts

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
