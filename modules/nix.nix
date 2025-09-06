{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  options.hostConfiguration.stable = lib.mkEnableOption "Use stable nixpkgs";

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
      registry = let
        inherit (config.hostConfiguration) stable;
      in {
        nixpkgs = {
          flake =
            if stable
            then inputs.nixpkgs-stable
            else inputs.nixpkgs;
        };
      };

      # Add nixpkgs input to NIX_PATH, to make nix2 commands consistent with the flake.
      nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
    };
  };
}
