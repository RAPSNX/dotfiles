{
  lib,
  mylib,
  config,
  pkgs,
  ...
}:
with lib;
with mylib;
let
  cfg = config.hostConfiguration.user;
in
{
  options.hostConfiguration.user = with types; {
    name = mkOpt str "Name of user.";
    initialHashedPassword = mkOpt str "Password of user.";
    keys = mkOpt (listOf str) "Public SSH keys of user.";
    extraGroups = mkOpt' (listOf str) [ ] "Additional groups for the user.";
    extraOptions = mkOpt attrs "Additional options for the user.";
  };

  config = {
    users.users.${cfg.name} = {
      isNormalUser = if cfg.name == "root" then false else true;

      shell = pkgs.zsh;

      initialHashedPassword = mkForce cfg.initialHashedPassword;
      openssh.authorizedKeys.keys = cfg.keys;

      extraGroups = [
        "wheel"
        "video"
        "audio"
      ]
      ++ cfg.extraGroups;
    }
    // cfg.extraOptions;

    # User config
    programs.zsh.enable = true;
    system.userActivationScripts.zshrc = "touch .zshrc"; # Prevent new user dialog
    environment.pathsToLink = [
      "/share/zsh" # autocompletion
      "/share/xdg-desktop-portal"
    ];
    services.openssh.enable = true;
    nix.optimise.automatic = true;
    system.stateVersion = "24.11";
  };
}
