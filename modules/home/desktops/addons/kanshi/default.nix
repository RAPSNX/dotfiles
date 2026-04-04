{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings = [
      {
        profile = {
          name = "firefly-undocked";
          outputs = [
            {
              criteria = "eDP-1";
              scale = 1.0;
              status = "enable";
            }
          ];
        };
      }

      {
        profile = {
          name = "firefly-home";
          outputs = [
            {
              criteria = "DP-1";
              position = "2560,0";
              mode = "3840x2160@143.99Hz";
            }
            {
              criteria = "HDMI-A-1";
              scale = 1.0;
              position = "0,0";
              mode = "2560x1440@144.00Hz";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }

      {
        profile = {
          name = "zion-home";
          outputs = [
            {
              criteria = "DP-1";
              position = "2560,0";
              mode = "3840x2160@239.99Hz";
            }
            {
              criteria = "DP-2";
              scale = 1.0;
              position = "0,0";
              mode = "2560x1440@144.00Hz";
            }
          ];
        };
      }

      {
        profile = {
          name = "firefly-office";
          outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "DP-8";
              position = "0,0";
            }
            {
              criteria = "DP-9";
              position = "1920,0";
            }
          ];
        };
      }
    ];
  };
}
