{
  workspace = [
    # Special
    "special:scratchy"
    "special:aux"
  ];

  bind = [
    # Workspace selection
    "bind = SUPER,1, workspace, 1"
    "bind = SUPER,2, workspace, 2"
    "bind = SUPER,3, workspace, 3"
    "bind = SUPER,4, workspace, 4"
    "bind = SUPER,5, workspace, 5"
    "bind = SUPER,6, workspace, 6"
    "bind = SUPER,7, workspace, 7"
    "bind = SUPER,8, workspace, 8"
    "bind = SUPER,9, workspace, 9"

    # Workspace window movement
    "ALT,1, movetoworkspace, 1"
    "ALT,2, movetoworkspace, 2"
    "ALT,3, movetoworkspace, 3"
    "ALT,4, movetoworkspace, 4"
    "ALT,5, movetoworkspace, 5"
    "ALT,6, movetoworkspace, 6"

    # Special workpace handling
    "SUPER,O, togglespecialworkspace, scratchy"
    "SUPER,M, togglespecialworkspace, aux"
    "SUPER SHIFT,O, movetoworkspace, special:scratchy"
    "SUPER SHIFT,M, movetoworkspace, special:aux"
  ];
}
