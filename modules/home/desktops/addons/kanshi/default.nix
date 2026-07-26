{
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";

    settings = [
      {
        output = {
          criteria = "eDP-1";
          position = "6000,0";
          mode = "1920x1200@60.00Hz";
        };
      }

      {
        profile = {
          name = "undocked";
          outputs = [
            {
              criteria = "eDP-1";
            }
          ];
        };
      }

      {
        profile = {
          name = "office";
          outputs = [
            {
              # TODO: test this connector, may overload this config with all possible connectors
              criteria = "DP-1";
              mode = "3440x1440@99.98Hz";
              scale = 1.0;
            }
            {
              criteria = "eDP-1";
            }
          ];
        };
      }

      # TODO: Add meeting room here

      {
        profile = {
          name = "home-firefly";
          outputs = [
            {
              criteria = "Dell Inc. AW2725Q G2QC174";
              scale = 1.5;
              position = "2560,0";
              mode = "3840x2160@239.99Hz";
            }
            {
              criteria = "Samsung Electric Company LC27G7xT H4ZNC00167";
              scale = 1.0;
              position = "0,0";
              mode = "2560x1440@239.96Hz";
            }
            {
              criteria = "eDP-1";
            }
          ];
        };
      }

      {
        profile = {
          name = "home";
          outputs = [
            {
              criteria = "Dell Inc. AW2725Q G2QC174";
              scale = 1.5;
              position = "2560,0";
              mode = "3840x2160@239.99Hz";
            }
            {
              criteria = "Samsung Electric Company LC27G7xT H4ZNC00167";
              scale = 1.0;
              position = "0,0";
              mode = "2560x1440@239.96Hz";
            }
          ];
        };
      }
    ];
  };
}
