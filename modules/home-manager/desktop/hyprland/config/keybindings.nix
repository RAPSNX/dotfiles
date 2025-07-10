{
  pkgs,
  config,
  ...
}: {
  wayland.windowManager.hyprland.extraConfig = ''
    # Workspace actions
    bind = SUPER,1, workspace, 1
    bind = SUPER,2, workspace, 2
    bind = SUPER,3, workspace, 3
    bind = SUPER,6, workspace, 4
    bind = SUPER,7, workspace, 5
    bind = SUPER,8, workspace, 6

    bind = ALT,Q, movetoworkspace, 1
    bind = ALT,W, movetoworkspace, 2
    bind = ALT,E, movetoworkspace, 3
    bind = ALT,Z, movetoworkspace, 4
    bind = ALT,U, movetoworkspace, 5
    bind = ALT,I, movetoworkspace, 6

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

    # Programms
    bind = SUPER,RETURN, exec, ${(config.lib.nixGL.wrap pkgs.alacritty)}/bin/alacritty
    bind = SUPER,SPACE, exec, ${pkgs.wofi}/bin/wofi --show=drun -a
    bind = SUPER,P, exec, ${pkgs.wlogout}/bin/wlogout
    bind = SUPER,Q, killactive

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
