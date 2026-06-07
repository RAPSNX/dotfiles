{
  programs.krewfile = {
    enable = true;

    plugins = [
      "krew"
      "explore"
      "modify-secret"
      "neat"
      "oidc-login"
      "pv-migrate"
      "stern"
      "node-shell"
      "ns"
      "ctx"
      "klock"
    ];
  };
}
