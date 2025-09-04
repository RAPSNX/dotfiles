{
  lib,
  config,
  ...
}: let
  # TODO: remove
  cfg = config.roles.desktop.hyprland;
in {
  imports = [
    ./keybindings.nix
    ./windowrules.nix
  ];

  wayland.windowManager.hyprland.settings = lib.mkIf cfg.enable {
    source = [
      "~/.config/hypr/monitors.conf"
    ];
  };
}
