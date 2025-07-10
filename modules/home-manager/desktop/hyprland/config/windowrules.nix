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
      "name:term, monitor:${primary}"
      "name:browser, monitor:${primary}"
      "name:spare, monitor:${primary}"

      # Secondary
      "name:browser2, monitor:${secondary}"
      "name:pass, monitor:${secondary}"
      "name:spare2, monitor:${secondary}"

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
  };
}
