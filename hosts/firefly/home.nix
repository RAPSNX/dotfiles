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
        configOnly = true;

        hyprlock.enable = false;
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
        [ -n "$GCTL_SESSION_ID" ] || [ -n "$TERM_SESSION_ID" ] || export GCTL_SESSION_ID="$(< /proc/sys/kernel/random/uuid)"
        GCTL_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/gardenctl/completion.zsh"
        if [ ! -f "$GCTL_CACHE" ]; then
          mkdir -p "''${GCTL_CACHE%/*}"
          gardenctl completion zsh > "$GCTL_CACHE" 2>/dev/null
        fi
        [ -f "$GCTL_CACHE" ] && source "$GCTL_CACHE"
        eval $(gardenctl kubectl-env zsh)
      '';
    };
  };

  home.packages = builtins.attrValues {
    inherit (pkgs)
      stackit-cli
      openstackclient
      vault-bin
      brightnessctl
      gcc
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
