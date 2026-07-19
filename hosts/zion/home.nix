{
  lib,
  pkgs,
  config,
  ...
}:
{
  home = {
    username = "rap";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
  };

  sops.age = {
    generateKey = false;
    keyFile = "${config.home.homeDirectory}/.config/sops/age/yubikey-identity.txt";
  };

  roles = {
    work = false;
    email = "mail@rapsn.me";

    desktop = {
      hyprland = {
        enable = true;
        package = pkgs.hyprland;

        hyprlock.enable = true;
        hypridle = {
          enable = true;
          cmd = "${pkgs.hyprlock}/bin/hyprlock";
        };
        autostart = [
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" # Needed for thunar
          "firefox"
          "ddcutil --display 2 setvcp 60 0x09" # Focus secondary display
        ];
      };
    };
  };
}
