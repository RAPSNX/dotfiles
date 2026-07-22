{
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.niri;
in
{
  options.roles.desktop.niri.enable = lib.mkEnableOption "Enable niri";

  # Migrated from modules/home/desktops/hyprland/keybinds.nix.
  # Only binds with a direct niri equivalent are included; modal submaps,
  # special workspaces, and hyprctl-scripted binds have no niri equivalent
  # and were left out of this PoC.
  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;

      settings.binds = {
        "Mod+Return".action.spawn = "alacritty";
        "Mod+E".action.spawn = "fuzzel";
        "Mod+P".action.spawn = "wlogout";
        "Mod+Q".action.close-window = [ ];

        "Mod+N".action.spawn = [
          "swaync-client"
          "-t"
        ];

        "Mod+F".action.fullscreen-window = [ ];

        "Mod+H".action.focus-column-left = [ ];
        "Mod+J".action.focus-window-down = [ ];
        "Mod+K".action.focus-window-up = [ ];
        "Mod+L".action.focus-column-right = [ ];

        "Mod+Shift+H".action.move-column-left = [ ];
        "Mod+Shift+J".action.move-window-down = [ ];
        "Mod+Shift+K".action.move-window-up = [ ];
        "Mod+Shift+L".action.move-column-right = [ ];

        "Mod+U".action.toggle-window-floating = [ ];

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;

        "Mod+Z".action.spawn = [
          "mumble"
          "rpc"
          "togglemute"
        ];
        "Mod+Shift+Z".action.spawn = [
          "mumble"
          "rpc"
          "toggledeaf"
        ];

        "Mod+Period".action.spawn = [
          "rofimoji"
          "--action"
          "copy"
          "type"
        ];

        "Mod+Shift+I".action.spawn = [
          "systemctl"
          "restart"
          "--user"
          "kanshi.service"
        ];
      };
    };

    xdg.configFile = {
      # Links the package-shipped niri systemd units into ~/.config/systemd/user,
      # since home.packages alone doesn't register them (that only happens
      # automatically on NixOS, via environment.systemPackages unit scanning).
      "systemd/user/niri.service".source =
        "${config.programs.niri.package}/share/systemd/user/niri.service";
      "systemd/user/niri-shutdown.target".source =
        "${config.programs.niri.package}/share/systemd/user/niri-shutdown.target";

      # Stops sd-switch from restarting the live compositor on every
      # home-manager switch. Both this override and the base niri.service must
      # live under .config/systemd/user/ -- that's the only directory the
      # activation script passes to sd-switch.
      "systemd/user/niri.service.d/overrides.conf".text = ''
        [Unit]
        X-SwitchMethod=keep-old
      '';
    };
  };
}
