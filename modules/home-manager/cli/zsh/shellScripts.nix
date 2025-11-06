{pkgs, ...}: let
  # nix helpers
  nix-run = pkgs.writeShellScriptBin "nr" ''
    #!/usr/bin/env bash
    nix run $(printf 'nixpkgs#%s ' "$@") --command zsh
  '';

  nix-shell = pkgs.writeShellScriptBin "ns" ''
    #!/usr/bin/env bash
    nix shell $(printf 'nixpkgs#%s ' "$@") --command zsh
  '';

  # kubeconfig selector
  select-kc = pkgs.writeShellScriptBin "select_kc" ''
    #!/usr/bin/env bash
    BASE_PATH=$HOME/.config/kubeconfig
    YAMLS=$(find "$BASE_PATH" -name '*.yaml' | awk -F/ '{ print $NF }')
    KUBECONFIG=$(fzf <<<"$YAMLS")
    export KUBECONFIG=$BASE_PATH/$KUBECONFIG
  '';
in {
  home.packages = [
    nix-run
    nix-shell
    select-kc
  ];
}
