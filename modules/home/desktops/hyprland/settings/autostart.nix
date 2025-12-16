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
      # TODO: Move to own option, build function for uwsm
      "uwsm app -- ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      "[ workspace special:scratchy silent ] alacritty -t scratchy"
      "sleep 5 && hyprctl dispatch closewindow class:ZSTray"
      "sleep 5 && uwsm app -- mumble --tray"
    ];
  };
}
