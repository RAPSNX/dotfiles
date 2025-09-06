{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.user;
in {
  options.hostConfiguration.user = with types; {
    name = mkOption {type = str;};
    initialHashedPassword = mkOption {type = str;};
    keys = mkOption {type = listOf str;};
    extraGroups = mkOption {
      type = listOf str;
      default = [];
      description = "Additional groups for the user.";
    };
    extraOptions = mkOption {
      type = attrs;
      description = "Additional options for the user.";
    };
  };

  config = {
    users.users.${cfg.name} =
      {
        isNormalUser =
          if cfg.name == "root"
          then false
          else true;

        shell = pkgs.zsh;

        initialHashedPassword = mkForce cfg.initialHashedPassword;
        openssh.authorizedKeys.keys = cfg.keys;

        extraGroups =
          [
            "wheel"
            "video"
            "audio"
          ]
          ++ cfg.extraGroups;
      }
      // cfg.extraOptions;

    # User config
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        plugins = [
          "git"
          "kubectl"
          "fzf"
        ];
      };
    };
    system.userActivationScripts.zshrc = "touch .zshrc"; # Prevent new user dialog
    environment.pathsToLink = [
      "/share/zsh" # autocompletion
      "/share/xdg-desktop-portal"
    ];
    services.openssh.enable = true;
  };
}
