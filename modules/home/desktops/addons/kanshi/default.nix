{ config, ... }:
{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.1;
            status = "enable";
          }
        ];
      }

      {
        profile.name = "home-office";
        profile.outputs = with config.roles.desktop.monitors; [
          {
            # Main
            criteria = main;
            position = "2560,0";
            mode = "3840x2160@143.99Hz";
          }
          {
            # Left
            criteria = left;
            scale = 1.0;
            position = "0,0";
            mode = "2560x1440@144.00Hz";
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      }

      {
        profile.name = "office";
        profile.outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
          }
          {
            criteria = "DP-8";
            position = "1536,0";
          }
          {
            criteria = "DP-9";
            position = "3456,0";
          }
        ];
      }

    ];
  };
}
