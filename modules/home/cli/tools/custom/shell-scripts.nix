{ pkgs, lib, ... }:
let
  # nix helpers
  nix-run = pkgs.writeShellScriptBin "nr" ''
    nix run $(printf 'nixpkgs#%s ' "$@")
  '';

  nix-shell = pkgs.writeShellScriptBin "ns" ''
    nix shell $(printf 'nixpkgs#%s ' "$@")
  '';

  # kubeconfig selector
  selc_ = pkgs.writeShellScriptBin "selc_" ''
    fail() {
      printf 'selc: %s\n' "$1" >&2
      return 1 2>/dev/null || exit 1
    }

    BASE_PATH="''${KUBECONFIG_DIR:-$HOME/.config/kubeconfig}"
    if [ ! -d "$BASE_PATH" ] && [ -d "$HOME/.config/kubeconfigs" ]; then
      BASE_PATH="$HOME/.config/kubeconfigs"
    fi

    [ -d "$BASE_PATH" ] || fail "kubeconfig directory not found: $BASE_PATH"

    KUBECONFIG_NAME=$(
      find "$BASE_PATH" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) -printf '%f\n' \
        | sort \
        | fzf --prompt='kubeconfig> '
    )

    [ -n "$KUBECONFIG_NAME" ] || fail "no kubeconfig selected"

    export KUBECONFIG="$BASE_PATH/$KUBECONFIG_NAME"
    printf 'KUBECONFIG=%s\n' "$KUBECONFIG"
  '';
in
{
  home.packages = lib.attrValues {
    inherit
      nix-run
      nix-shell
      selc_
      ;
  };
}
