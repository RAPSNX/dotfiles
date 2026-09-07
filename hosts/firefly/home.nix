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
      noctalia = {
        enable = true;
        externalLockCommand = "/usr/bin/swaylock --daemonize";
        polkitAgent = false;
      };

      hyprland.enable = true;
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

  xdg = {
    # Wayland session definition for display managers
    dataFile."wayland-sessions/hyprland-nix.desktop".text = ''
      [Desktop Entry]
      Name=Hyprland (Nix)
      Comment=Hyprland with Nix-managed runtime libraries
      Exec=${config.home.homeDirectory}/.nix-profile/bin/start-hyprland
      Type=Application
      DesktopNames=Hyprland
      Keywords=tiling;wayland;compositor;
    '';

    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];

      config = {
        common.default = [
          "hyprland"
          "gtk"
        ];

        hyprland.default = [
          "hyprland"
          "gtk"
        ];

        gnome.default = [
          "gnome"
          "gtk"
        ];
      };
    };
  };

  # NOTE: Need to add also portal and gtk, because otherwise the ubuntu portal will not discover the
  # hyprland portal (hardcoded path)
  systemd.user.packages = [
    pkgs.xdg-desktop-portal
    pkgs.xdg-desktop-portal-gtk
    config.wayland.windowManager.hyprland.finalPortalPackage
  ];

  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };
}
