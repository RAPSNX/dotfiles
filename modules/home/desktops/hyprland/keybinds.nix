{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;
  toggleFirefox = pkgs.writeShellScriptBin "toggleFirefox" ''
    #!/usr/bin/env bash
    set -euo pipefail

    CLASS="firefox"
    DEDICATED_WS="3"

    current_ws="$(hyprctl activeworkspace -j | jq -r '.id')"

    firefox_on_current="$(
      hyprctl clients -j | jq -r --arg class "$CLASS" --argjson ws "$current_ws" '
        any(.[]; (.class | ascii_downcase) == $class and .workspace.id == $ws)
      '
    )"

    if [[ "$firefox_on_current" == "true" ]]; then
      hyprctl dispatch movetoworkspacesilent "$DEDICATED_WS,class:$CLASS"
    else
      hyprctl dispatch movetoworkspace "+0,class:$CLASS"
    fi
  '';
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.extraLuaFiles."keybinds" = ''
      -- Common
      hl.bind("SUPER", "RETURN", "exec, alacritty")
      hl.bind("SUPER", "E", "exec, noctalia msg panel-toggle launcher")
      hl.bind("SUPER", "P", "exec, noctalia msg panel-toggle session")
      hl.bind("SUPER", "Q", "killactive")
      hl.bind("ALT", "TAB", "exec, noctalia msg window-switcher")

      -- Window actions
      hl.bind("SUPER", "F", "fullscreen, 1")
      hl.bind("SUPER+SHIFT", "F", "fullscreen")

      -- Movement
      hl.bind("SUPER", "H", "movefocus, l")
      hl.bind("SUPER", "J", "movefocus, d")
      hl.bind("SUPER", "K", "movefocus, u")
      hl.bind("SUPER", "L", "movefocus, r")

      -- Window movement
      hl.bind("SUPER+SHIFT", "H", "movewindow, l")
      hl.bind("SUPER+SHIFT", "J", "movewindow, d")
      hl.bind("SUPER+SHIFT", "K", "movewindow, u")
      hl.bind("SUPER+SHIFT", "L", "movewindow, r")

      -- Layout toggle
      hl.bind("SUPER", "T", "layoutmsg, togglesplit")
      hl.bind("SUPER", "U", "togglefloating,")

      -- Workspace selection
      hl.bind("SUPER", "1", "workspace, 1")
      hl.bind("SUPER", "2", "workspace, 2")
      hl.bind("SUPER", "3", "workspace, 3")
      hl.bind("SUPER", "4", "workspace, 4")
      hl.bind("SUPER", "5", "workspace, 5")

      -- Workspace handling scratchy
      hl.bind("SUPER", "O", "togglespecialworkspace, scratchy")
      hl.bind("SUPER", "M", "togglespecialworkspace, aux")
      hl.bind("SUPER SHIFT", "O", "movetoworkspace, special:scratchy")
      hl.bind("SUPER SHIFT", "M", "movetoworkspace, special:aux")

      -- Programs
      hl.bind("SUPER", "Z", "exec, mumble rpc togglemute")
      hl.bind("SUPER+SHIFT", "Z", "exec, mumble rpc toggledeaf")
      hl.bind("SUPER", "period", 'exec, noctalia msg panel-toggle launcher "/emo "')
      hl.bind("SUPER+SHIFT", "I", "exec, systemctl restart --user kanshi.service")

      -- Mouse binds
      hl.bindm("SUPER", "mouse:272", "movewindow")
      hl.bindm("SUPER", "mouse:273", "resizewindow")

      -- Noctalia Mode
      hl.define_submap("noctalia", function()
        hl.bind("", "n", "exec, noctalia msg panel-toggle control-center notifications; noctalia msg notification-clear-active")
        hl.bind("", "n", "submap, reset")

        hl.bind("", "m", "exec, noctalia msg panel-toggle control-center monitor; noctalia msg notification-clear-active")
        hl.bind("", "m", "submap, reset")

        hl.bind("", "c", "exec, noctalia msg panel-toggle control-center calendar; noctalia msg notification-clear-active")
        hl.bind("", "c", "submap, reset")

        hl.bind("", "s", "exec, noctalia msg screenshot-region; noctalia msg notification-clear-active")
        hl.bind("", "s", "submap, reset")

        hl.bind("SHIFT", "S", "exec, noctalia msg screenshot-fullscreen; noctalia msg notification-clear-active")
        hl.bind("SHIFT", "S", "submap, reset")

        hl.bind("", "a", 'exec, ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.satty} --filename -; noctalia msg notification-clear-active')
        hl.bind("", "a", "submap, reset")

        hl.bind("", "return", "exec, noctalia msg notification-clear-active")
        hl.bind("", "return", "submap, reset")
        hl.bind("", "escape", "exec, noctalia msg notification-clear-active")
        hl.bind("", "escape", "submap, reset")
      end)
      hl.bind("SUPER", "N", "exec, noctalia msg notification-show 'MODE: NOCTALIA' '[n] Notifications  [m] Monitor  [c] Calendar  [s] Region  [S] Full  [a] Annotate'")
      hl.bind("SUPER", "N", "submap, noctalia")

      -- Resize mode
      hl.define_submap("resize", function()
        hl.bind("", "H", "resizeactive, -60 0")
        hl.bind("", "J", "resizeactive, 0 60")
        hl.bind("", "K", "resizeactive, 0 -60")
        hl.bind("", "L", "resizeactive, 60 0")

        hl.bind("SHIFT", "H", "resizeactive, -20 0")
        hl.bind("SHIFT", "J", "resizeactive, 0 20")
        hl.bind("SHIFT", "K", "resizeactive, 0 -20")
        hl.bind("SHIFT", "L", "resizeactive, 20 0")

        hl.bind("", "return", "exec, noctalia msg notification-clear-active")
        hl.bind("", "return", "submap, reset")
        hl.bind("", "escape", "exec, noctalia msg notification-clear-active")
        hl.bind("", "escape", "submap, reset")
      end)
      hl.bind("SUPER", "R", "exec, noctalia msg notification-show 'MODE: RESIZE' '[H/J/K/L] Resize  [Shift+H/J/K/L] Fine  [Esc/Enter] Exit'")
      hl.bind("SUPER", "R", "submap, resize")

      -- Window mode
      hl.define_submap("windows", function()
        hl.bind("", "Q", "movetoworkspace, 1")
        hl.bind("", "Q", "exec, noctalia msg notification-clear-active")
        hl.bind("", "Q", "submap, reset")

        hl.bind("", "W", "movetoworkspace, 2")
        hl.bind("", "W", "exec, noctalia msg notification-clear-active")
        hl.bind("", "W", "submap, reset")

        hl.bind("", "E", "movetoworkspace, 3")
        hl.bind("", "E", "exec, noctalia msg notification-clear-active")
        hl.bind("", "E", "submap, reset")

        hl.bind("", "R", "movetoworkspace, 4")
        hl.bind("", "R", "exec, noctalia msg notification-clear-active")
        hl.bind("", "R", "submap, reset")

        -- Special app toggle
        hl.bind("", "B", "exec, ${lib.getExe toggleFirefox}; noctalia msg notification-clear-active")
        hl.bind("", "B", "submap, reset")

        hl.bind("", "return", "exec, noctalia msg notification-clear-active")
        hl.bind("", "return", "submap, reset")
        hl.bind("", "escape", "exec, noctalia msg notification-clear-active")
        hl.bind("", "escape", "submap, reset")
      end)
      hl.bind("SUPER", "G", "exec, noctalia msg notification-show 'MODE: WINDOWS' '[Q/W/E/R] Move to WS  [B] Toggle Firefox  [Esc/Enter] Exit'")
      hl.bind("SUPER", "G", "submap, windows")
    '';
  };
}
