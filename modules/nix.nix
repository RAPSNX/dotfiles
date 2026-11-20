{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  config = {
    nixpkgs.config = {
      # Allow unfree packages globally.
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };

    nix = {
      # Use the Nix package provided by the current nixpkgs input.
      package = lib.mkDefault pkgs.nix;

      settings = {
        # Enable the modern Nix CLI and flakes.
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Do not warn when evaluating flakes from a dirty Git working tree.
        warn-dirty = false;

        # Automatically accept nixConfig settings declared by flakes.
        accept-flake-config = true;

        extra-substituters = [
          "https://noctalia.cachix.org"
          "https://nkl-sofka.cachix.org"
        ];

        extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          "nkl-sofka.cachix.org-1:hLg9frFNJynrxe7SSBb/p6pbawlpZmG10bw+wLsTufw="
        ];

      };

      # Make `nixpkgs` resolve to the same nixpkgs input used by this flake.
      registry.nixpkgs.flake = inputs.nixpkgs;

      # Keep legacy NIX_PATH based commands consistent with the flake input.
      nixPath = [
        "nixpkgs=${inputs.nixpkgs.outPath}"
      ];
    };
  };
}
