{
  lib,
  config,
  pkgs,
  ...
}:
{

  home = {
    username = "raphaelgroemmer";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
  };

  roles = {
    work = true;
    email = "raphael.groemmer@digits.schwarz";

    apparmor-gen = [
      config.programs.chromium.finalPackage
      pkgs.obsidian
    ];

    desktop = {
      hyprland = {
        enable = true;
        package = pkgs.hyprland;

        hyprlock.enable = true;
        hypridle = {
          enable = true;
          cmd = "/usr/bin/swaylock";
        };
        autostart = [
          "sleep 3 && mumble" # Need to sleep for tray icon
          "firefox"
          "chromium"
        ];
      };
    };

    cli = {
      zsh.zshrc = ''
        [ -n "$GCTL_SESSION_ID" ] || [ -n "$TERM_SESSION_ID" ] || export GCTL_SESSION_ID=$(uuidgen)
        source <(gardenctl completion zsh)
        eval $(gardenctl kubectl-env zsh)
      '';
    };
  };

  home.packages = lib.attrValues {
    inherit (pkgs)
      stackit-cli
      openstackclient-full
      vault-bin
      brightnessctl
      ;

    inherit (pkgs.mypkgs)
      gardenctl
      gardenlogin
      ;
  };

  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };
}
