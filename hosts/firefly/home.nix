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
    configFile = {
      "autostart/nm-applet.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=NetworkManager Applet
        Comment=Manage your network connections
        Icon=nm-device-wireless
        Exec=nm-applet
        Terminal=false
        NoDisplay=true
        NotShowIn=KDE;GNOME;Hyprland;
        X-GNOME-UsesNotifications=true
        X-Ubuntu-Gettext-Domain=nm-applet
      '';

      "autostart/blueman.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Blueman Applet
        Comment=Blueman Bluetooth Manager
        Icon=blueman
        Exec=blueman-applet
        Terminal=false
        NotShowIn=Hyprland;
      '';

      "autostart/update-notifier.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Update Notifier
        Icon=update-notifier
        Exec=update-notifier
        Terminal=false
        NoDisplay=true
        NotShowIn=KDE;Hyprland;
        X-GNOME-Autostart-Delay=60
        X-Ubuntu-Gettext-Domain=update-notifier
      '';
    };

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
  };

  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };
}
