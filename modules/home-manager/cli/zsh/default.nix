{
  pkgs,
  lib,
  config,
  ...
}:
with lib; {
  imports = [
    ./shellScripts.nix
    ./starship.nix
  ];

  home.packages = [pkgs.zsh-completions];

  catppuccin.zsh-syntax-highlighting.enable = true;

  programs.zsh = let
    homeDir = config.home.homeDirectory;
  in {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    dotDir = "${homeDir}/.config/zsh";

    enableCompletion = true;
    completionInit = "";

    zprof.enable = true;

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";

      # pinentry for sign commits with gpg
      GPG_TTY = "$(tty)";

      # disable highlight of history-substring-search
      HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND = "";
      POWERLEVEL9K_INSTANT_PROMPT = "quiet";
    };

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 1000000000;
      size = 1000000000;
      share = true;
    };

    # TODO: readd this
    # # Gardenctl
    # [ -n "$GCTL_SESSION_ID" ] || [ -n "$TERM_SESSION_ID" ] || export GCTL_SESSION_ID=$(uuidgen)
    # source <(gardenctl completion zsh)
    # eval $(gardenctl kubectl-env zsh)
    initContent = lib.mkMerge [
      (lib.mkOrder 500
        '''')
      (lib.mkOrder 1000
        '''')
      (lib.mkOrder 1500
        '''')
    ];

    shellAliases = {
      # Overwrites
      cat = "bat";
      ls = "exa --icons";
      ll = "exa --icons -la";
      cd = "z";
      j = "z";
      n = "nix-shell -p";

      # Shortcuts
      clr = "clear";
      tf = "terraform";

      g = "gardenctl";
      gtcp = "gardenctl target control-plane";
      gos = "eval $(gardenctl provider-env zsh)";
      o = "openstack";

      k = "kubectl";
      kk = "k9s";
      clean = "nix-collect-garbage -d && nix-store --gc && nix-store --verify --check-contents --repair";

      selc = "source select_kc";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "kubectl"
      ];
    };

    plugins = with pkgs; [
      {
        name = "zsh-autopair";
        src = fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
        file = "autopair.zsh";
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = "${zsh-nix-shell}/share/zsh-nix-shell";
      }
    ];
  };
}
