{
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.sway;
in
{
  options.roles.desktop.sway.enable = lib.mkEnableOption "Enable sway";

  # Migrated from modules/home/desktops/hyprland/keybinds.nix.
  # Sway's own default keybindings (splith/splitv, scratchpad, exit dialog,
  # etc.) are replaced entirely (lib.mkForce) rather than merged in, to keep
  # this migration predictable -- only what's listed below exists.
  # Special workspaces (two independently toggleable named scratch areas)
  # and the hyprctl-scripted firefox toggle have no clean sway equivalent and
  # were left out, same as the niri migration. Unlike niri, sway's real
  # `mode` blocks are a direct equivalent of Hyprland's submaps, so the
  # resize and window-move submaps *are* migrated here.
  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;

      config = {
        modifier = "Mod4";
        terminal = "alacritty";
        menu = "fuzzel";

        keybindings = lib.mkForce {
          "Mod4+Return" = "exec alacritty";
          "Mod4+e" = "exec fuzzel";
          "Mod4+p" = "exec wlogout";
          "Mod4+q" = "kill";

          "Mod4+n" = "exec swaync-client -t";

          "Mod4+f" = "fullscreen toggle";

          "Mod4+h" = "focus left";
          "Mod4+j" = "focus down";
          "Mod4+k" = "focus up";
          "Mod4+l" = "focus right";

          "Mod4+Shift+h" = "move left";
          "Mod4+Shift+j" = "move down";
          "Mod4+Shift+k" = "move up";
          "Mod4+Shift+l" = "move right";

          "Mod4+t" = "layout toggle split";
          "Mod4+u" = "floating toggle";

          "Mod4+1" = "workspace number 1";
          "Mod4+2" = "workspace number 2";
          "Mod4+3" = "workspace number 3";
          "Mod4+4" = "workspace number 4";
          "Mod4+5" = "workspace number 5";

          "Mod4+z" = "exec mumble rpc togglemute";
          "Mod4+Shift+z" = "exec mumble rpc toggledeaf";

          "Mod4+period" = "exec rofimoji --action copy type";

          "Mod4+Shift+i" = "exec systemctl restart --user kanshi.service";

          "Mod4+r" = "mode resize";
          "Mod4+g" = "mode window";
        };

        modes = lib.mkForce {
          resize = {
            "h" = "resize shrink width 60px";
            "j" = "resize grow height 60px";
            "k" = "resize shrink height 60px";
            "l" = "resize grow width 60px";

            "Shift+h" = "resize shrink width 20px";
            "Shift+j" = "resize grow height 20px";
            "Shift+k" = "resize shrink height 20px";
            "Shift+l" = "resize grow width 20px";

            "Return" = "mode default";
            "Escape" = "mode default";
          };

          window = {
            "q" = "move container to workspace number 1; mode default";
            "w" = "move container to workspace number 2; mode default";
            "e" = "move container to workspace number 3; mode default";
            "r" = "move container to workspace number 4; mode default";

            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };
      };
    };
  };
}
