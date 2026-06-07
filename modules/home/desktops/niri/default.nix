{
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.niri;
  inherit (config.lib.niri) actions;
in
{
  options.roles.desktop.niri = {
    enable = lib.mkEnableOption "Enable hyprland";
  };

  config = lib.mkIf cfg.enable {
    # TODO: WIP - Niri is currently in a trial phase.
    # This config needs to be updated in a seperate PR, when niri got evaluated.
    programs.niri = {
      enable = true;

      settings = {

        input = {
          keyboard = {
            xkb = {
              layout = "eu";
            };

            repeat-delay = 150;
            repeat-rate = 45;
          };

          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
        };

        outputs = {
          "DP-1" = {
            mode = {
              width = 3840;
              height = 2160;
              refresh = 239.991;
            };
            scale = 1.5;
            position = {
              x = 0;
              y = 0;
            };
          };
        };

        workspaces = {
          "term" = {
            open-on-output = "DP-1";
          };
          "code" = {
            open-on-output = "DP-1";
          };
          "spare" = {
            open-on-output = "DP-1";
          };
          "browser" = {
            open-on-output = "DP-2";
          };
          "chat" = {
            open-on-output = "DP-2";
          };
          "gear" = {
            open-on-output = "DP-2";
          };
        };

        prefer-no-csd = true;

        layout = {
          gaps = 8;
          default-column-width = {
            proportion = 0.5;
          };
          preset-column-widths = [
            { proportion = 0.25; }
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];
        };

        window-rules = [
          {
            clip-to-geometry = true;
            geometry-corner-radius = {
              bottom-left = 10.0;
              bottom-right = 10.0;
              top-left = 10.0;
              top-right = 10.0;
            };
            open-maximized = true;
          }
        ];

        binds = {
          "Mod+Return".action.spawn = [ "alacritty" ];
          "Mod+E".action.spawn = [ "fuzzel" ];
          "Mod+P".action.spawn = [ "wlogout" ];

          "Mod+Q".action = actions."close-window";
          "Mod+F".action = actions."fullscreen-window";

          "Mod+H".action = actions."focus-column-or-monitor-left";
          "Mod+L".action = actions."focus-column-or-monitor-right";
          "Mod+J".action = actions."focus-window-or-workspace-down";
          "Mod+K".action = actions."focus-window-or-workspace-up";

          # Smart movement: move within monitor, then to adjacent monitor when at edge
          "Mod+Shift+H".action = actions."consume-or-expel-window-left";
          "Mod+Shift+L".action = actions."consume-or-expel-window-right";

          # then reorder inside the column (up/down)
          "Mod+Shift+K".action = actions."move-window-up";
          "Mod+Shift+J".action = actions."move-window-down";

          "Mod+R".action = actions."switch-preset-column-width";
          "Mod+Shift+R".action = actions."switch-preset-column-width-back";

          "Mod+1".action.focus-workspace = "term";
          "Mod+2".action.focus-workspace = "code";
          "Mod+3".action.focus-workspace = "spare";
          "Mod+4".action.focus-workspace = "browser";
          "Mod+5".action.focus-workspace = "chat";
          "Mod+6".action.focus-workspace = "gear";
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;

          # Move only window to workspace (not whole column)
          "Mod+Alt+1".action.move-window-to-workspace = 1;
          "Mod+Alt+2".action.move-window-to-workspace = 2;
          "Mod+Alt+3".action.move-window-to-workspace = 3;
          "Mod+Alt+4".action.move-window-to-workspace = 4;
          "Mod+Alt+5".action.move-window-to-workspace = 5;
          "Mod+Alt+6".action.move-window-to-workspace = 6;
          "Mod+Alt+7".action.move-window-to-workspace = 7;
          "Mod+Alt+8".action.move-window-to-workspace = 8;
          "Mod+Alt+9".action.move-window-to-workspace = 9;
        };
      };
    };
  };
}
