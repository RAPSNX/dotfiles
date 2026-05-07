{
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      bind = [
        # Common
        "SUPER,RETURN, exec, alacritty"
        "SUPER,E, exec, fuzzel"
        "SUPER,P, exec, wlogout"
        "SUPER,Q, killactive"

        # Notification center
        "SUPER,N, exec, swaync-client -t"

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
        "SUPER,6, workspace, 6"
        "SUPER,7, workspace, 7"
        "SUPER,8, workspace, 8"
        "SUPER,9, workspace, 9"

        # Workspace window movement
        "ALT,1, movetoworkspace, 1"
        "ALT,2, movetoworkspace, 2"
        "ALT,3, movetoworkspace, 3"
        "ALT,4, movetoworkspace, 4"
        "ALT,5, movetoworkspace, 5"
        "ALT,6, movetoworkspace, 6"
        "ALT,7, movetoworkspace, 7"
        "ALT,8, movetoworkspace, 8"

        # Workpace handling sratchy
        "SUPER,O, togglespecialworkspace, scratchy"
        "SUPER,M, togglespecialworkspace, aux"
        "SUPER SHIFT,O, movetoworkspace, special:scratchy"
        "SUPER SHIFT,M, movetoworkspace, special:aux"

        # -- Programs

        # Mumble
        "SUPER,Z, exec, mumble rpc togglemute"
        "SUPER+SHIFT,Z, exec, mumble rpc toggledeaf"

        # Emoji picker
        "SUPER,period, exec, rofimoji --action copy --action type"

        # Emoji picker
        "SUPER,I, exec, systemctl restart --user kanshi.service"
      ];

      extraConfig = ''
        # Resize mouse
        bindm = SUPER, mouse:272, movewindow
        bindm = SUPER, mouse:273, resizewindow

        # Resize mode
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

          bind = , return, submap, reset
          bind = , escape, submap, reset
        submap = reset


        # Window mode
        bind = SUPER, G, submap, windows

        submap = windows
          bind = , Q, movetoworkspace, 1
          bind = , Q, submap, reset

          bind = , W, movetoworkspace, 2
          bind = , W, submap, reset

          bind = , E, movetoworkspace, 3
          bind = , E, submap, reset

          bind = , R, movetoworkspace, 4
          bind = , R, submap, reset

          bind = , B, movetoworkspace, +0,class:firefox
          bind = , B, submap, reset

          bind = SHIFT, B, movetoworkspacesilent, 3,class:firefox
          bind = SHIFT, B, submap, reset

          bind = , return, submap, reset
          bind = , escape, submap, reset
        submap = reset
      '';
    };
  };
}
