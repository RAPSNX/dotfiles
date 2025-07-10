{
  pkgs,
  config,
  ...
}: let
  userEmail =
    if config.roles.workdevice
    then "raphael.groemmer@stackit.cloud"
    else "github@rapsn.me";

  myGit = pkgs.git.override {
    withLibsecret = true;
  };
in {
  home.packages = with pkgs; [
    gh
  ];

  programs = {
    git = {
      enable = true;
      inherit userEmail;
      package = myGit;
      userName = "RAPSNX";

      delta.enable = true;
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

      extraConfig = {
        credential.helper = "${myGit}/bin/git-credential-libsecret";
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
      ];
    };
  };
}
