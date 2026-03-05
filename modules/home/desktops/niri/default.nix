{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with lib;
with mylib;
with pkgs;
let
  cfg = config.roles.desktop.niri;
in
{
  options.roles.desktop.niri = {
    enable = mkEnableOption "Enable hyprland";
  };

  config = lib.mkIf cfg.enable {
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
          "DP-1" = {
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

        binds = with config.lib.niri.actions; {
          "Mod+Return".action.spawn = [ "alacritty" ];
          "Mod+E".action.spawn = [ "fuzzel" ];
          "Mod+P".action.spawn = [ "wlogout" ];

          "Mod+Q".action = close-window;
          "Mod+F".action = fullscreen-window;

          "Mod+H".action = focus-column-or-monitor-left;
          "Mod+L".action = focus-column-or-monitor-right;
          "Mod+J".action = focus-window-or-workspace-down;
          "Mod+K".action = focus-window-or-workspace-up;

          # Smart movement: move within monitor, then to adjacent monitor when at edge
          "Mod+Shift+H".action = consume-or-expel-window-left;
          "Mod+Shift+L".action = consume-or-expel-window-right;

          # then reorder inside the column (up/down)
          "Mod+Shift+K".action = move-window-up;
          "Mod+Shift+J".action = move-window-down;

          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-column-width-back;

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
