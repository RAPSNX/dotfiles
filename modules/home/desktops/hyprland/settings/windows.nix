{
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    windowrule = [
      "match:class ^(firefox)$, workspace 4"
      "match:class ^(chromium-browser)$, workspace 5"

      "match:class ^(.*mumble.*)$, workspace special:aux silent"
      "match:class ^(.*keepassxc.*)$, workspace special:aux silent"

      # Force floating
      "match:class steam, float yes"
      "match:class ^(.*nextcloud.*)$, float yes"
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
  };
}
