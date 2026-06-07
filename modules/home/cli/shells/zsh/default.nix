{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
{
  options.roles.cli.zsh.zshrc = mylib.mkOpt' lib.types.str "" "Extra content for zshrc";

  config = {
    home.packages = builtins.attrValues {
      inherit (pkgs) zsh-completions;
    };

    catppuccin.zsh-syntax-highlighting.enable = true;

    programs.zsh = {
      enable = true;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      dotDir = "${config.home.homeDirectory}/.config/zsh";

      enableCompletion = true;

      sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";

        # disable highlight of history-substring-search
        HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND = "";
      };

      history = {
        expireDuplicatesFirst = true;
        ignoreDups = true;
        ignoreSpace = true;
        save = 1000000000;
        size = 1000000000;
        share = true;
      };

      initContent = lib.mkMerge [
        (lib.mkOrder 500 "")
        (lib.mkOrder 1000 ''
          export GOPATH=$(go env GOPATH)
          ${config.roles.cli.zsh.zshrc}
        '')
        (lib.mkOrder 1500 "")
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
        kk = "k9s -c pods";
        kns = "kubectl ns";
        selc = "source selc_";

        clean = "nix-collect-garbage -d && nix-store --gc && nix-store --verify --check-contents --repair";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "kubectl"
        ];
      };

      plugins = [
        {
          name = "zsh-autopair";
          src = pkgs.fetchFromGitHub {
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
          src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
        }
      ];
    };
  };
}
