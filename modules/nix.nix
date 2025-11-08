{
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = {
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    nix = {
      package = lib.mkDefault pkgs.nix;

      gc.randomizedDelaySec = "10min";

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
      };

      # Add nixpkgs flake input as a registry to make nix3 commands consistent with the flake.
      registry = {
        nixpkgs = {
          flake = inputs.nixpkgs;
        };
      };

      # Add nixpkgs input to NIX_PATH, to make nix2 commands consistent with the flake.
      nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
    };
  };
}
