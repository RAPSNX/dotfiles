{
  lib,
  mylib,
  config,
  ...
}:
with lib;
with mylib;
let
  cfg = config.roles.desktop.hyprland;
in
{
  config = {
    wayland.windowManager.hyprland.settings = mkIf cfg.enable {
      workspace = [
        # Special
        "special:scratchy"
        "special:aux"
      ];

      bind = [
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

        # Special workpace handling
        "SUPER,O, togglespecialworkspace, scratchy"
        "SUPER,M, togglespecialworkspace, aux"
        "SUPER SHIFT,O, movetoworkspace, special:scratchy"
        "SUPER SHIFT,M, movetoworkspace, special:aux"
      ];
    };
  };
}
