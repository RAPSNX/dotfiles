{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.roles.desktop.hyprland;
  primary = (elemAt cfg.monitors 1).ID;
  secondary = (elemAt cfg.monitors 0).ID;
in {
  wayland.windowManager.hyprland.settings = {
    workspace = [
      # Main
      "name:1, monitor:${primary}" # Terminal
      "name:2, monitor:${primary}" # Browser
      "name:3, monitor:${primary}" # Spare

      # Secondary
      "name:4, monitor:${secondary}" # Browser
      "name:5, monitor:${secondary}" # Keepass
      "name:6, monitor:${secondary}" # Spare

      # Special
      "special:scratchy"
      "special:aux"
    ];

    windowrule = [
      "float, class:steam"
      "size 70% 70%, class:steam"
      "center, class:steam"

      "float, class:com.nextcloud.desktopclient.nextcloud"
      "size 20% 50%, class:com.nextcloud.desktopclient.nextcloud"
      "move 79% 3%, class:com.nextcloud.desktopclient.nextcloud"
    ];

    windowrulev2 = [
      "workspace 1, class:^(Alacritty)$"
      "workspace 4, class:^(firefox_firefox)$"

      "workspace special:aux, class:^(.*mumble.*)$"
      "workspace special:aux, class:^(.*ZSTray.*)$"
    ];
  };
}
