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

  # UMU uses Steam's Proton 11+ runtime instead of maintaining a second copy.
  xdg.dataFile."umu/steamrt4" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4";
    force = true;
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
