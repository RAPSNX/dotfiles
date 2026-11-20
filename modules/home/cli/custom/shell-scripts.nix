{ pkgs, ... }:
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
    BASE_PATH=$HOME/.config/kubeconfigs
    YAMLS=$(find "$BASE_PATH" -name '*.yaml' | awk -F/ '{ print $NF }')
    KUBECONFIG=$(fzf <<<"$YAMLS")
    export KUBECONFIG="$BASE_PATH/$KUBECONFIG"
  '';

  devbox-proxy_ = pkgs.writeShellScriptBin "devbox-proxy_" ''
    up() { (exec 3<>/dev/tcp/127.0.0.1/$1) 2>/dev/null; }
    up 1080 || ssh -fN devbox
    up 8118 || (setsid gost -L http://127.0.0.1:8118 -F socks5://127.0.0.1:1080 >/dev/null 2>&1 &)

    unset -f up
    export HTTP_PROXY=http://127.0.0.1:8118 HTTPS_PROXY=http://127.0.0.1:8118
    echo "exit IP: $(curl -sS -m 10 --retry 3 --retry-connrefused --retry-delay 1 -x "$HTTPS_PROXY" https://ifconfig.me)"
  '';
in
{
  home.packages = [
    nix-run
    nix-shell
    selc_
    devbox-proxy_
  ];
}
