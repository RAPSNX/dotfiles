{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.roles.desktop.hyprland;
in {
  wayland.windowManager.hyprland.settings = mkIf cfg.enable {
    workspace = [
      # # Main
      # "name:1, monitor:${primary}" # Terminal
      # "name:2, monitor:${primary}" # Browser
      # "name:3, monitor:${primary}" # Spare
      #
      # # Secondary
      # "name:4, monitor:${secondary}" # Browser
      # "name:5, monitor:${secondary}" # Keepass
      # "name:6, monitor:${secondary}" # Spare

      # Special
      "special:scratchy"
      "special:aux"
    ];

    windowrule = [
      "float, class:steam"

      "float, class:com.nextcloud.desktopclient.nextcloud"
      "size 20% 50%, class:com.nextcloud.desktopclient.nextcloud"
      "move 79% 3%, class:com.nextcloud.desktopclient.nextcloud"
    ];

    windowrulev2 = [
      "workspace 1, class:^(Alacritty)$"
      "workspace 4, class:^(firefox_firefox)$"
      "workspace 5, class:^(chromium-browser)$"

      "workspace special:aux silent, class:^(.*mumble.*)$"
      "workspace special:aux silent, class:^(.*ZSTray.*)$"
    ];
  };
}
