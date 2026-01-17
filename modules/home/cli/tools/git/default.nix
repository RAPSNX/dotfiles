{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    gh
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
          condition = "gitdir:~/Projects/rgroemmer/**";
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
