{pkgs, ...}: let
  # nix helper aliases
  nix_run = pkgs.writeShellScriptBin "nr" ''
    #!/usr/bin/env bash
    nix run nixpkgs#"$@"
  '';
  nix_shell = pkgs.writeShellScriptBin "ns" ''
    #!/usr/bin/env bash
    nix shell nixpkgs#"$@"
  '';
  selc = pkgs.writeShellScriptBin "selc" ''
    #!/usr/bin/env bash
    BASE_PATH=$HOME/.config/kubeconfig
    YAMLS=$(find "$BASE_PATH" -name '*.yaml' | awk -F/ '{ print $NF }')
    KUBECONFIG=$(fzf <<<"$YAMLS")
    export KUBECONFIG=$BASE_PATH/$KUBECONFIG
  '';
in {
  home.packages = [
    nix_run
    nix_shell
    selc
  ];
}
