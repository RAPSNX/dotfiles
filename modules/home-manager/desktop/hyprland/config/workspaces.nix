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

    # Workspace window movement
    "bind = ALT,1, movetoworkspace, 1"
    "bind = ALT,2, movetoworkspace, 2"
    "bind = ALT,3, movetoworkspace, 3"
    "bind = ALT,4, movetoworkspace, 4"
    "bind = ALT,5, movetoworkspace, 5"
    "bind = ALT,6, movetoworkspace, 6"

    # Special workpace handling
    "bind = SUPER,O, togglespecialworkspace, scratchy"
    "bind = SUPER,M, togglespecialworkspace, aux"
    "bind = SUPER SHIFT,O, movetoworkspace, special:scratchy"
    "bind = SUPER SHIFT,M, movetoworkspace, special:aux"
  ];
}
