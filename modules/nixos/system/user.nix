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
    name = mylib.mkOpt lib.types.str "Username for the account.";
    initialHashedPassword = mylib.mkOpt lib.types.str "Initial hashed password for the account.";
    extraGroups = mylib.mkOpt' (lib.types.listOf lib.types.str) [ ] "Additional supplemental groups.";
    extraOptions = mylib.mkOpt lib.types.attrs "Extra user account options.";
  };

  config = {
    users.users.${cfg.name} = {
      isNormalUser = if cfg.name == "root" then false else true;

      shell = pkgs.zsh;

      initialHashedPassword = lib.mkForce cfg.initialHashedPassword;
      openssh.authorizedKeys.keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1twcfSmy7xyUA5iWl51kfBHS1Dxpmmog0x55Z6HRNlAAAABHNzaDo= swiss"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKX8MmA9KdHCny6rKCGZlyd/J5qCXh+YDM0/3ZGDmfyaAAAABHNzaDo= yubi"
      ];

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
