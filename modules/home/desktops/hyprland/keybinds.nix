[
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
  "SUPER,T, togglesplit,"
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
  "SUPER,period, exec, rofimoji"
]
