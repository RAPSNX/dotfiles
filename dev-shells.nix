{
  pkgs ? import <nixpkgs> { },
  pre-commit-hooks,
  ...
}:
let
  pre-commit-check = pre-commit-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
    src = ./.;
    hooks = {
      statix.enable = true;
      nixfmt.enable = true;
      deadnix.enable = true;
    };
  };
  mkTargets = t: builtins.mapAttrs (name: script: pkgs.writeShellScriptBin name script) t;
in
{
  default = pkgs.mkShell {
    inherit (pre-commit-check) shellHook;

    packages = builtins.attrValues (
      {
        inherit (pkgs)
          nh
          statix
          deadnix
          nixfmt
          nix-inspect
          nix-tree
          ;
      }
      // mkTargets {
        check = "nix flake check";

        sw-zion = ''
          nh os switch && nh home switch
        '';

        swh-zion = ''
          nh home switch
        '';

        swo-zion = ''
          nh os switch
        '';

        sw-fly = ''
          nh home switch -c nix@firefly . --show-activation-logs
        '';

        bld-fly = ''
          nh home build -c nix@firefly . --show-activation-logs
        '';

        bld-iso = ''
          nix build .#nixosConfigurations.vinox.config.system.build.isoImage
        '';

        swr-kubex = ''
          nh os boot --hostname kubex . -d always --target-host kubex
        '';

        swr-berry = ''
          nh os boot --hostname nixberry . -d always --target-host nixberry
        '';
      }
    );

    NIX_CONFIG = "experimental-features = nix-command flakes";
  };
}
