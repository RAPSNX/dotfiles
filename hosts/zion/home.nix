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

  # TODO: Check if this is needed
  # UMU uses Steam's Proton 11+ runtime instead of maintaining a second copy.
  # xdg.dataFile."umu/steamrt4" = {
  #   source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4";
  #   force = true;
  # };

  roles = {
    work = false;
    email = "mail@rapsn.me";

    desktop = {
      noctalia = {
        enable = true;
        windowsReboot.enable = true;
      };

      hyprland = {
        enable = true;
        package = pkgs.hyprland;
        autostart = [
          "firefox"
          "ddcutil --display 2 setvcp 60 0x09" # Focus secondary display
        ];
      };
    };
  };
}
