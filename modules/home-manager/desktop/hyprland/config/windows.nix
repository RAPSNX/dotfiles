{
  windowrule = [
    # Force floating
    "float, class:steam"
    "float, class:com.nextcloud.desktopclient.nextcloud"

    # Resize
    "size 20% 50%, class:com.nextcloud.desktopclient.nextcloud"
    "move 78% 4%, class:com.nextcloud.desktopclient.nextcloud"
    "move 68% 4%, class:^(.*ZSTray.*)$"
  ];

  windowrulev2 = [
    "workspace 4, class:^(firefox_firefox)$"
    "workspace 5, class:^(chromium-browser)$"

    "workspace special:aux silent, class:^(.*mumble.*)$"
    "workspace special:aux silent, class:^(.*keepassxc.*)$"
  ];

  bind = [
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
    "SUPER,T, togglesplit,"
    "SUPER,U, togglefloating,"
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
  '';
}
