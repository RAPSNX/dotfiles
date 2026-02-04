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
in
{
  default =
    with pkgs;
    mkShell {
      inherit (pre-commit-check) shellHook;

      packages = [
        nh
        statix
        deadnix
        nixfmt
        nix-inspect
      ];
    };
}
