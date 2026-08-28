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
      hl.bind("ALT", "V", "exec, noctalia msg panel-toggle clipboard")

      -- Noctalia panels
      hl.bind("SUPER", "N", "exec, noctalia msg panel-toggle control-center notifications")
      hl.bind("MOD5", "C", "exec, noctalia msg panel-toggle control-center calendar")
      hl.bind("MOD5", "S", "exec, noctalia msg panel-toggle control-center monitor")
      hl.bind("MOD5", "V", "exec, noctalia msg panel-toggle clipboard")

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

        hl.bind("", "return", "submap, reset")
        hl.bind("", "escape", "submap, reset")
      end)
      hl.bind("SUPER", "R", "submap, resize")

      -- Window mode
      hl.define_submap("windows", function()
        hl.bind("", "Q", "movetoworkspace, 1")
        hl.bind("", "Q", "submap, reset")

        hl.bind("", "W", "movetoworkspace, 2")
        hl.bind("", "W", "submap, reset")

        hl.bind("", "E", "movetoworkspace, 3")
        hl.bind("", "E", "submap, reset")

        hl.bind("", "R", "movetoworkspace, 4")
        hl.bind("", "R", "submap, reset")

        -- Special app toggle
        hl.bind("", "B", "exec, ${lib.getExe toggleFirefox}")

        hl.bind("", "return", "submap, reset")
        hl.bind("", "escape", "submap, reset")
      end)
      hl.bind("SUPER", "G", "submap, windows")
    '';
  };
}
