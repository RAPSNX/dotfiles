{
  lib,
  pkgs,
  mylib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.niri;

  # Niri has no scratchpad, unlike sway, but its IPC can address windows by
  # id directly (niri msg action focus-window/move-window-to-workspace),
  # which is enough to reconstruct a real hide/show toggle: hide by moving
  # the window to a dedicated, otherwise-unused named workspace; show by
  # moving it back to whatever workspace is currently focused and focusing
  # it. This is a single script invoked per keypress, not a persistent
  # daemon.
  toggleScratchy = pkgs.writeShellScript "toggle-scratchy" ''
    set -euo pipefail

    scratchy_id=$(niri msg --json windows | ${lib.getExe pkgs.jq} -r '
      .[] | select(.app_id == "Alacritty" and .title == "scratchy") | .id
    ' | head -n1)

    if [ -z "$scratchy_id" ]; then
      exit 0
    fi

    is_focused=$(niri msg --json windows | ${lib.getExe pkgs.jq} -r --argjson id "$scratchy_id" '
      .[] | select(.id == $id) | .is_focused
    ')

    if [ "$is_focused" = "true" ]; then
      niri msg action move-window-to-workspace --window-id "$scratchy_id" --focus false "scratch-hidden"
    else
      current_idx=$(niri msg --json workspaces | ${lib.getExe pkgs.jq} -r '.[] | select(.is_focused == true) | .idx')
      niri msg action move-window-to-workspace --window-id "$scratchy_id" --focus false "$current_idx"
      niri msg action focus-window --id "$scratchy_id"
    fi
  '';
in
{
  options.roles.desktop.niri = {
    enable = lib.mkEnableOption "Enable niri";
    autostart = mylib.mkOpt (lib.types.listOf lib.types.str) "autostart";
  };

  # Migrated from modules/home/desktops/hyprland/keybinds.nix.
  # Only binds with a direct niri equivalent are included; modal submaps,
  # special workspaces, and hyprctl-scripted binds have no niri equivalent
  # and were left out of this PoC.
  config = lib.mkIf cfg.enable {
    # niri.service itself BindsTo graphical-session.target (there's no
    # dedicated niri-session.target the way Hyprland/sway each have one),
    # so that's what waybar binds against here.
    programs.waybar.systemd.targets = lib.mkDefault [ "graphical-session.target" ];

    programs.niri = {
      enable = true;

      settings = {
        layout = {
          gaps = 10;
          border.enable = true;
          border.width = 3;
        };

        # Parking spot for the scratchy toggle script (see toggleScratchy
        # above) -- deliberately not bound to any Mod+N workspace-switch
        # key, so it's never visible during regular use.
        workspaces."scratch-hidden" = { };

        input = {
          keyboard = {
            xkb = {
              layout = "eu,de,de";
              variant = ",neo_qwertz,";
            };
            repeat-delay = 250;
            repeat-rate = 40;
          };
          mouse = {
            accel-profile = "flat";
            accel-speed = 1.0;
          };
        };

        # spawn-at-startup runs each command directly (not through a shell),
        # so autostart entries with shell syntax (&&, etc.) need "sh" "-c".
        spawn-at-startup = [
          {
            command = [
              "alacritty"
              "-t"
              "scratchy"
            ];
          }
        ]
        ++ map (cmd: {
          command = [
            "sh"
            "-c"
            cmd
          ];
        }) cfg.autostart;

        window-rules = [
          {
            # Default: rounded corners everywhere (native niri feature, no
            # SwayFX-style fork needed). No `matches` means it applies to
            # every window.
            geometry-corner-radius = {
              top-left = 5.0;
              top-right = 5.0;
              bottom-left = 5.0;
              bottom-right = 5.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [
              { app-id = "^steam$"; }
              { app-id = ".*nextcloud.*"; }
            ];
            open-floating = true;
          }
          {
            matches = [
              {
                app-id = "^Alacritty$";
                title = "^scratchy$";
              }
            ];
            open-floating = true;
          }
          {
            # Hardcoded to firefly's real secondary monitor from the
            # "home-firefly" kanshi profile (modules/home/desktops/addons/kanshi).
            # Not dynamic across locations/profiles: at other kanshi profiles
            # (office/home) this output doesn't exist, so per niri's own
            # fallback behaviour the window just opens on the currently
            # focused output instead of erroring.
            matches = [
              { app-id = "^firefox$"; }
              { app-id = "^chromium.*"; }
            ];
            open-on-output = "Samsung Electric Company LC27G7xT H4ZNC00167";
          }
        ];

        binds = {
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

          "Mod+O".action.spawn = "${toggleScratchy}";

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
