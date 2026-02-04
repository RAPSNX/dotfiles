{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;
in
{
  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    exec-once = [
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      "[ workspace special:scratchy silent ] alacritty -t scratchy"
    ];
  };
}
