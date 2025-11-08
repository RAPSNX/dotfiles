{
  wayland.windowManager.hyprland.extraConfig = ''
    # Workspace actions
    bind = SUPER,1, workspace, 1
    bind = SUPER,2, workspace, 2
    bind = SUPER,3, workspace, 3
    bind = SUPER,4, workspace, 4
    bind = SUPER,5, workspace, 5
    bind = SUPER,6, workspace, 6

    bind = ALT,1, movetoworkspace, 1
    bind = ALT,2, movetoworkspace, 2
    bind = ALT,3, movetoworkspace, 3
    bind = ALT,4, movetoworkspace, 4
    bind = ALT,5, movetoworkspace, 5
    bind = ALT,6, movetoworkspace, 6
    bind = ALT,6, movetoworkspace, 7

    bind = SUPER,O, togglespecialworkspace, scratchy
    bind = SUPER,M, togglespecialworkspace, aux

    bind = SUPER SHIFT,O, movetoworkspace, special:scratchy
    bind = SUPER SHIFT,M, movetoworkspace, special:aux

    # Window actions
    bind = SUPER,F, fullscreen, 1
    bind = SUPER+SHIFT,F, fullscreen

    bind = SUPER+SHIFT,H, movewindow,l
    bind = SUPER+SHIFT,J, movewindow, d
    bind = SUPER+SHIFT,K, movewindow, u
    bind = SUPER+SHIFT,L, movewindow, r

    # Layout action
    bind = SUPER,T, togglesplit,
    bind = SUPER,U, togglefloating,

    # Movement
    bind = SUPER,H, movefocus, l
    bind = SUPER,J, movefocus, d
    bind = SUPER,K, movefocus, u
    bind = SUPER,L, movefocus, r

    # Resize
    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow

    bind = SUPER, R, submap, resize

    # Resize mode
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
  '';
}
