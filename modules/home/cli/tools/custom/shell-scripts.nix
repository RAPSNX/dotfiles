{ pkgs, ... }:
let
  # nix helpers
  nix-run = pkgs.writeShellScriptBin "nr" ''
    #!/usr/bin/env bash
    nix run $(printf 'nixpkgs#%s ' "$@")
  '';

  nix-shell = pkgs.writeShellScriptBin "ns" ''
    #!/usr/bin/env bash
    nix shell $(printf 'nixpkgs#%s ' "$@")
  '';

  # kubeconfig selector
  selc_ = pkgs.writeShellScriptBin "selc_" ''
    #!/usr/bin/env bash
    BASE_PATH=$HOME/.config/kubeconfig
    YAMLS=$(find "$BASE_PATH" -name '*.yaml' | awk -F/ '{ print $NF }')
    KUBECONFIG=$(fzf <<<"$YAMLS")
    export KUBECONFIG=$BASE_PATH/$KUBECONFIG
  '';
in
{
  home.packages = [
    nix-run
    nix-shell
    selc_
  ];
}
