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
