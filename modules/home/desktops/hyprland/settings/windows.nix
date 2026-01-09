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
      # Force floating
      "float, class:steam"
      "float, class:com.nextcloud.desktopclient.nextcloud"

      # Resize
      "size 20% 50%, class:com.nextcloud.desktopclient.nextcloud"
      "move 78% 4%, class:com.nextcloud.desktopclient.nextcloud"
      "move 68% 4%, class:^(.*ZSTray.*)$"
      "move 40% 40%, title:^(.*Mumble Server Connect.*)$"
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

  };
}
