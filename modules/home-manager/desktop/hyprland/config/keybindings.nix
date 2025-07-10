{
  pkgs,
  config,
  ...
}: {
  wayland.windowManager.hyprland.extraConfig = ''
    bind = SUPER SHIFT,O, movetoworkspace, special
    bind = SUPER+SHIFT,F, fullscreen
    bind = SUPER+SHIFT,H, movewindow,l
    bind = SUPER+SHIFT,J, movewindow, d
    bind = SUPER+SHIFT,K, movewindow, u
    bind = SUPER+SHIFT,L, movewindow, r
    bind = SUPER+SHIFT,S, movetoworkspace, 4
    bind = SUPER,1, workspace, 1
    bind = SUPER,2, workspace, 2
    bind = SUPER,3, workspace, 3
    bind = SUPER,6, workspace, 4
    bind = SUPER,7, workspace, 5
    bind = SUPER,8, workspace, 6
    bind = SUPER,F, fullscreen, 1
    bind = SUPER,O, togglespecialworkspace, scratchy
    bind = SUPER,M, togglespecialworkspace, aux
    bind = SUPER,Q, killactive
    bind = SUPER,R, togglesplit,
    bind = SUPER,RETURN, exec, ${(config.lib.nixGL.wrap pkgs.alacritty)}/bin/alacritty
    bind = SUPER,S, movetoworkspace, 2
    bind = SUPER,SPACE, exec, ${pkgs.wofi}/bin/wofi --show=drun -a
    bind = SUPER,P, exec, ${pkgs.wlogout}/bin/wlogout
    bind = SUPER,T, togglefloating,
    bind = SUPER,H, movefocus, l
    bind = SUPER,J, movefocus, d
    bind = SUPER,K, movefocus, u
    bind = SUPER,L, movefocus, r

    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow
  '';
}
