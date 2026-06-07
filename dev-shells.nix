{
  pkgs ? import <nixpkgs> { },
  pre-commit-hooks,
  lib ? pkgs.lib,
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

  # Makefile like targets
  switch-firefly = pkgs.writeShellScriptBin "switch-firefly" ''
    NIX_CONFIG="experimental-features = nix-command flakes" \
      nh home switch -c nix@firefly . --show-activation-logs
  '';

  switch-zion = pkgs.writeShellScriptBin "switch-zion" ''
    nh os switch && nh home switch
  '';
in
{
  default = pkgs.mkShell {
    inherit (pre-commit-check) shellHook;

    packages = lib.attrValues {
      inherit (pkgs)
        nh
        statix
        deadnix
        nixfmt
        nix-inspect
        ;

      inherit
        switch-firefly
        switch-zion
        ;
    };
  };
}
