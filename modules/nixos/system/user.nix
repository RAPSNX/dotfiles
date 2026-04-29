{
  lib,
  mylib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.user;
in
{
  options.hostConfig.user = {
    name = mylib.mkOpt lib.types.str "Name of user.";
    initialHashedPassword = mylib.mkOpt lib.types.str "Password of user.";
    keys = mylib.mkOpt (lib.types.listOf lib.types.str) "Public SSH keys of user.";
    extraGroups = mylib.mkOpt' (lib.types.listOf lib.types.str) [ ] "Additional groups for the user.";
    extraOptions = mylib.mkOpt lib.types.attrs "Additional options for the user.";
  };

  config = {
    users.users.${cfg.name} = {
      isNormalUser = if cfg.name == "root" then false else true;

      shell = pkgs.zsh;

      initialHashedPassword = lib.mkForce cfg.initialHashedPassword;
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
