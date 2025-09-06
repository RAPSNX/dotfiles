{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (inputs) nixGL;
in {
  imports = [
    # module inputs
    inputs.catppuccin.homeModules.catppuccin
    inputs.neonix.homeManagerModules.neonix
    inputs.krewfile.homeManagerModules.krewfile
    inputs.sops-nix.homeManagerModules.sops

    # custom module config definition
    ./modules.nix

    # global nix & nixpkgs settings
    ../../nix.nix
  ];

  nixGL =
    if config.roles.useNixGL
    then {
      inherit (nixGL) packages;
      defaultWrapper = "mesa";
    }
    else {};

  sops.secrets.ssh_config = {
    sopsFile = ./secrets.yaml;
    path = "${config.home.homeDirectory}/.ssh/config";
    mode = "600";
  };

  programs.home-manager.enable = true;
  xdg.enable = true;

  news = {
    display = "silent";
    json = lib.mkForce {};
    entries = lib.mkForce [];
  };
}
