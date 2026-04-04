{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings =
      let
        main = "Dell Inc. AW2725Q G2QC174";
        left = "Samsung Electric Company LC27G7xT H4ZNC00167";
      in
      [
        {
          profile = {
            name = "undocked";
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
            name = "home-office";
            outputs = [
              {
                criteria = main;
                position = "2560,0";
                mode = "3840x2160@143.99Hz";
              }
              {
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
            exec = [
              "hyprctl dispatch workspace 6 && hyprctl dispatch moveworkspacetomonitor 6 ${left}"
              "hyprctl dispatch workspace 5 && hyprctl dispatch moveworkspacetomonitor 5 ${left}"
              "hyprctl dispatch workspace 4 && hyprctl dispatch moveworkspacetomonitor 4 ${left}"

              "hyprctl dispatch workspace 3 && hyprctl dispatch moveworkspacetomonitor 3 ${main}"
              "hyprctl dispatch workspace 2 && hyprctl dispatch moveworkspacetomonitor 2 ${main}"
              "hyprctl dispatch workspace 1 && hyprctl dispatch moveworkspacetomonitor 1 ${main}"
            ];
          };
        }

        {
          profile = {
            name = "office";
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
            exec = [
              "hyprctl dispatch workspace 6 && hyprctl dispatch moveworkspacetomonitor 6 DP-9"
              "hyprctl dispatch workspace 5 && hyprctl dispatch moveworkspacetomonitor 5 DP-9"
              "hyprctl dispatch workspace 4 && hyprctl dispatch moveworkspacetomonitor 4 DP-9"

              "hyprctl dispatch workspace 3 && hyprctl dispatch moveworkspacetomonitor 3 DP-8"
              "hyprctl dispatch workspace 2 && hyprctl dispatch moveworkspacetomonitor 2 DP-8"
              "hyprctl dispatch workspace 1 && hyprctl dispatch moveworkspacetomonitor 1 DP-8"

            ];
          };
        }
      ];
  };
}
