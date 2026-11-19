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

  roles = {
    work = false;
    email = "mail@rapsn.me";

    desktop = {
      noctalia = {
        systemLoad.enable = true;
        enable = true;
        windowsReboot.enable = true;
      };

      hyprland = {
        enable = true;
        package = pkgs.hyprland;
        autostart = [
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "firefox"
        ];
      };
    };
  };

  wayland.windowManager.hyprland.settings = {
    config.render = {
      cm_enabled = true;
      # Switch only for fullscreen HDR surfaces; keep the desktop in SDR.
      # 1 uses standard BT.2020/PQ, 2 uses experimental EDID primaries.
      cm_auto_hdr = 1;
    };

    # Kanshi owns mode, position and scale. These rules supply color and VRR
    # policy without replacing its layout profiles.
    monitor = [
      {
        output = "desc:Dell Inc. AW2725Q G2QC174";
        cm = "srgb";
        bitdepth = 10;
        vrr = 2;
      }
      {
        output = "desc:Samsung Electric Company LC27G7xT H4ZNC00167";
        cm = "srgb";
        bitdepth = 10;
        vrr = 2;
      }
    ];
  };
}
