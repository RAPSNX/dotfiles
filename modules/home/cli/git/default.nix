{
  pkgs,
  config,
  ...
}:
{
  home.packages =
    let
      # Search through release notes
      ghr-grep = pkgs.writeShellScriptBin "ghr-grep" ''
        set -euo pipefail
        usage='usage: ghr-grep org/repo <count> "search_term"'
        repo="''${1:?$usage}"
        count="''${2:?$usage}"
        search_term="''${3:?$usage}"
        release_tags=$(gh release list -R "$repo" --limit "$count" | awk '{print $1}')

        for tag in $release_tags; do
            body="$(gh release view "$tag" -R "$repo" --json body -q .body)"
            if grep -qi -- "$search_term" <<<"$body"; then
                echo -e "\033[0;32m=== $tag ===\033[0m"
                grep -i -- "$search_term" <<<"$body"
                echo
            fi
        done
      '';
    in
    [
      pkgs.gh
      ghr-grep
    ];

  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;

      ignores = [
        ".idea"
        ".vs"
        ".vsc"
        ".vscode" # ide
        ".DS_Store" # mac
        "node_modules"
        "npm-debug.log" # npm
        "__pycache__"
        "*.pyc" # python
        ".ipynb_checkpoints" # jupyter
        "__sapper__" # svelte
      ];

      settings = {
        user = {
          name = "RAPSNX";
          inherit (config.roles) email;
        };

        credential.helper = "${pkgs.gitFull}/bin/git-credential-libsecret";
        commit = {
          gpgsign = false;
        };
        fetch.prune = true;
        init = {
          defaultBranch = "main";
        };
        pull = {
          ff = false;
          commit = false;
          rebase = true;
        };
        url = {
          # Fix for go mod tidy: use correct ssh url for azure
          "git@ssh.dev.azure.com:v3".insteadOf = "https://dev.azure.com";
        };
        push.autoSetupRemote = true;
        delta = {
          line-numbers = true;
        };
      };

      includes = [
        {
          condition = "gitdir:~/Projects/rapsnx/**";
          contents = {
            user.email = "github@rapsn.me";
          };
        }
        {
          condition = "gitdir:~/Projects/schwarzit/**";
          contents = {
            user.name = "Raphael Groemmer";
          };
        }
      ];
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
