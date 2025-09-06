{
  pkgs ? import <nixpkgs> {},
  pre-commit-hooks,
  ...
}: let
  pre-commit-check = pre-commit-hooks.lib.${pkgs.system}.run {
    src = ./.;
    hooks = {
      statix.enable = true;
      alejandra.enable = true;
      deadnix.enable = true;
    };
  };
in {
  default = with pkgs;
    mkShell {
      inherit (pre-commit-check) shellHook;

      packages = [
        nh
        statix
        deadnix
        alejandra
        nix-inspect
      ];
    };
}
