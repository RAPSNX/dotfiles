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
    wayland.windowManager.hyprland.settings = {
      bind = [
        # Common
        "SUPER,RETURN, exec, alacritty"
        "SUPER,E, exec, noctalia msg panel-toggle launcher"
        "SUPER,P, exec, noctalia msg panel-toggle session"
        "SUPER,Q, killactive"
        "ALT,TAB, exec, noctalia msg window-switcher"

        # Window actions
        "SUPER,F, fullscreen, 1"
        "SUPER+SHIFT,F, fullscreen"

        # Movement
        "SUPER,H, movefocus, l"
        "SUPER,J, movefocus, d"
        "SUPER,K, movefocus, u"
        "SUPER,L, movefocus, r"

        # Window movement
        "SUPER+SHIFT,H, movewindow,l"
        "SUPER+SHIFT,J, movewindow, d"
        "SUPER+SHIFT,K, movewindow, u"
        "SUPER+SHIFT,L, movewindow, r"

        # Layout toggle
        "SUPER,T, layoutmsg, togglesplit"
        "SUPER,U, togglefloating,"

        # Workspace selection
        "SUPER,1, workspace, 1"
        "SUPER,2, workspace, 2"
        "SUPER,3, workspace, 3"
        "SUPER,4, workspace, 4"
        "SUPER,5, workspace, 5"

        # Workspace handling scratchy
        "SUPER,O, togglespecialworkspace, scratchy"
        "SUPER,M, togglespecialworkspace, aux"
        "SUPER SHIFT,O, movetoworkspace, special:scratchy"
        "SUPER SHIFT,M, movetoworkspace, special:aux"

        # Programs
        "SUPER,Z, exec, mumble rpc togglemute"
        "SUPER+SHIFT,Z, exec, mumble rpc toggledeaf"
        "SUPER,period, exec, noctalia msg panel-toggle launcher /emo "
        "SUPER+SHIFT,I, exec, systemctl restart --user kanshi.service"
      ];

      extraConfig = ''
        # Mouse binds
        bindm = SUPER, mouse:272, movewindow
        bindm = SUPER, mouse:273, resizewindow

        #-- Noctalia Mode
        #
        bind = SUPER, N, exec, noctalia msg notification-show 'MODE: NOCTALIA' '[n] Notifications  [m] Monitor  [c] Calendar  [s] Region  [S] Full  [a] Annotate'
        bind = SUPER, N, submap, noctalia
        submap = noctalia
          bind = , n, exec, noctalia msg panel-toggle control-center notifications; noctalia msg notification-clear-active
          bind = , n, submap, reset

          bind = , m, exec, noctalia msg panel-toggle control-center monitor; noctalia msg notification-clear-active
          bind = , m, submap, reset

          bind = , c, exec, noctalia msg panel-toggle control-center calendar; noctalia msg notification-clear-active
          bind = , c, submap, reset

          bind = , s, exec, noctalia msg screenshot-region; noctalia msg notification-clear-active
          bind = , s, submap, reset

          bind = SHIFT, S, exec, noctalia msg screenshot-fullscreen; noctalia msg notification-clear-active
          bind = SHIFT, S, submap, reset

          bind = , a, exec, noctalia msg notification-clear-active; sleep 0.1; ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.satty} --filename -
          bind = , a, submap, reset

          bind = , return, exec, noctalia msg notification-clear-active
          bind = , return, submap, reset
          bind = , escape, exec, noctalia msg notification-clear-active
          bind = , escape, submap, reset
        submap = reset

        #-- Resize mode
        #
        bind = SUPER, R, exec, noctalia msg notification-show 'MODE: RESIZE' '[H/J/K/L] Resize  [Shift+H/J/K/L] Fine  [Esc/Enter] Exit'
        bind = SUPER, R, submap, resize
        submap = resize
          bind = , H, resizeactive, -60 0
          bind = , J, resizeactive, 0 60
          bind = , K, resizeactive, 0 -60
          bind = , L, resizeactive, 60 0

          bind = SHIFT, H, resizeactive, -20 0
          bind = SHIFT, J, resizeactive, 0 20
          bind = SHIFT, K, resizeactive, 0 -20
          bind = SHIFT, L, resizeactive, 20 0

          bind = , return, exec, noctalia msg notification-clear-active
          bind = , return, submap, reset
          bind = , escape, exec, noctalia msg notification-clear-active
          bind = , escape, submap, reset
        submap = reset

        #-- Window mode
        #
        bind = SUPER, G, exec, noctalia msg notification-show 'MODE: WINDOWS' '[Q/W/E/R] Move to WS  [B] Toggle Firefox  [Esc/Enter] Exit'
        bind = SUPER, G, submap, windows
        submap = windows
          bind = , Q, movetoworkspace, 1
          bind = , Q, exec, noctalia msg notification-clear-active
          bind = , Q, submap, reset

          bind = , W, movetoworkspace, 2
          bind = , W, exec, noctalia msg notification-clear-active
          bind = , W, submap, reset

          bind = , E, movetoworkspace, 3
          bind = , E, exec, noctalia msg notification-clear-active
          bind = , E, submap, reset

          bind = , R, movetoworkspace, 4
          bind = , R, exec, noctalia msg notification-clear-active
          bind = , R, submap, reset

          # Special app toggle
          bind = , B, exec, ${lib.getExe toggleFirefox}; noctalia msg notification-clear-active
          bind = , B, submap, reset

          bind = , return, exec, noctalia msg notification-clear-active
          bind = , return, submap, reset
          bind = , escape, exec, noctalia msg notification-clear-active
          bind = , escape, submap, reset
        submap = reset
      '';
    };
  };
}
