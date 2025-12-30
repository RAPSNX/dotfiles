{
  config,
  lib,
  mylib,
  ...
}:
with lib;
with mylib;
let
  cfg = config.roles.desktop.hyprland;
in
{
  options.roles.desktop.hyprland.extraConfig = with types; mkOpt str "Any hyprland extraConfig.";

  config = {
    wayland.windowManager.hyprland = lib.mkIf cfg.enable {
      extraConfig = ''
        # Resize mouse
        bindm = SUPER, mouse:272, movewindow
        bindm = SUPER, mouse:273, resizewindow

        # Resize mode
        bind = SUPER, R, submap, resize
        submap = resize
          bind = , H, resizeactive, -60 0
          bind = , J, resizeactive, 0 60
          bind = , K, resizeactive, 0 -60
          bind = , L, resizeactive, 60 0

          bind = SHIFT, H, resizeactive, -20 0
          bind = SHIFT, J, resizeactive, 0 20
          bind = SHIFT, K, resizeactive, 0 -20
          bind = SHIFT, L, resizeactive, 20 0

          bind = , return, submap, reset
          bind = , escape, submap, reset
        submap = reset
      ''
      + cfg.extraConfig;
    };
  };
}
