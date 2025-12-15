{inputs, ...}: {
  imports = [
    # external modules
    inputs.catppuccin.homeModules.catppuccin
    inputs.neonix.homeManagerModules.neonix
    inputs.krewfile.homeManagerModules.krewfile
    inputs.sops-nix.homeManagerModules.sops

    # internal modules
    ./common
    ./cli
    ./desktop
    ./roles

    # nix settings
    ../nix.nix
  ];
}
