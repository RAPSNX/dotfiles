{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;

  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua { };

  mkLuaArgs = args: { _args = args; };
  startHook = mkLuaInline ''
    function()
      hl.exec_cmd(${toLua "[ workspace special:scratchy silent ] alacritty -t scratchy"})
    end
  '';
in
{
  options.roles.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland";

    configOnly = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Generate Hyprland configuration without installing or managing the
        compositor or portal packages. Systemd session integration stays enabled
        so user services can bind to hyprland-session.target.
      '';
    };

    package = lib.mkPackageOption pkgs "hyprland" {
      nullable = true;
    };
  };

  imports = [
    ./keybinds.nix
    ./assertions.nix
  ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ pkgs.hyprshutdown ];

        catppuccin.hyprland.enable = false;

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "lua";

          inherit (cfg) package;

          # NOTE: Configures screen sharing to include the cursor, reuse approved sources through restore tokens, and capture at no more than 60 FPS.
          xdph.settings = {
            screencopy = {
              cursor_mode = 2;
              allow_token_by_default = true;
              max_fps = 60;
            };
          };

          systemd = {
            enable = true;
            # NOTE: Imports the live display and session identifiers into systemd so XDPH connects to the correct Hyprland instance; PATH must remain owned by environment.d.
            variables = [
              "DISPLAY"
              "WAYLAND_DISPLAY"
              "HYPRLAND_INSTANCE_SIGNATURE"
              "XDG_CURRENT_DESKTOP"
              "XDG_SESSION_DESKTOP"
              "XDG_SESSION_TYPE"
              "XDG_DATA_DIRS"
            ];
            enableXdgAutostart = true;
          };
          settings = {
            env = map mkLuaArgs [
              [
                "XDG_CURRENT_DESKTOP"
                "Hyprland"
              ]
              [
                "XDG_SESSION_DESKTOP"
                "Hyprland"
              ]
              [
                "XDG_SESSION_TYPE"
                "wayland"
              ]
            ];

            config = {
              general = {
                gaps_in = 8;
                gaps_out = 10;
                border_size = 3;
                col = {
                  active_border = {
                    colors = [
                      "rgba(cba6f7ee)"
                      "rgba(89b4faee)"
                    ];
                    angle = 45;
                  };
                  inactive_border = "rgba(585b70aa)";
                };
              };

              dwindle = {
                preserve_split = true;
                special_scale_factor = 0.8;
              };

              input = {
                kb_layout = "eu,de,de";
                kb_variant = ",neo_qwertz,";
                kb_options = "grp:alt_shift_toggle";
                repeat_rate = 40;
                repeat_delay = 250;
                accel_profile = "flat";
                sensitivity = 1;
              };

              xwayland.force_zero_scaling = true;

              misc = {
                lockdead_screen_delay = 5000;
                allow_session_lock_restore = true;
              };

              decoration = {
                blur = {
                  enabled = true;
                  size = 3;
                  passes = 2;
                  ignore_opacity = true;
                  new_optimizations = true;
                };

                rounding = 5;
              };
            };

            on = mkLuaArgs [
              "hyprland.start"
              startHook
            ];

            workspace_rule = [
              {
                workspace = "1";
                monitor = "desc:Dell Inc. AW2725Q G2QC174";
                default = true;
              }
              {
                workspace = "2";
                monitor = "desc:Dell Inc. AW2725Q G2QC174";
              }
              {
                workspace = "3";
                monitor = "desc:Samsung Electric Company LC27G7xT H4ZNC00167";
                default = true;
              }
              {
                workspace = "4";
                monitor = "desc:Samsung Electric Company LC27G7xT H4ZNC00167";
              }
            ];

            window_rule = [
              {
                match.class = "^(firefox)$";
                workspace = "3";
              }
              {
                match.class = "^(chromium-browser)$";
                workspace = "4";
              }
              {
                match.class = "^(.*mumble.*)$";
                workspace = "special:aux silent";
              }
              {
                match.class = "^(.*keepassxc.*)$";
                workspace = "special:aux silent";
              }
              {
                match.class = "steam";
                float = true;
              }
              {
                match.class = "^(.*nextcloud.*)$";
                float = true;
              }
            ];
          };
        };
      }

      # NOTE: Hyprland cannot safely replace its config parser while a session is running.
      (lib.mkIf (config.wayland.windowManager.hyprland.finalPackage != null) {
        xdg.configFile."hypr/hyprland.lua".onChange = lib.mkForce ''
          (
            XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
            if [[ -d "/tmp/hypr" || -d "$XDG_RUNTIME_DIR/hypr" ]]; then
              for instance in $(
                ${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl instances -j |
                  ${lib.getExe pkgs.jq} -r '.[].instance'
              ); do
                if ${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl -i "$instance" systeminfo |
                  ${lib.getExe pkgs.gnugrep} -q 'configProvider: lua'; then
                  ${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl -i "$instance" reload config-only
                fi
              done
            fi
          )
        '';
      })

      (lib.mkIf cfg.configOnly {
        wayland.windowManager.hyprland = {
          package = lib.mkForce null;
          portalPackage = lib.mkForce null;
        };

        xdg.portal.enable = lib.mkForce false;
      })

      # NOTE: Registers the portal frontend, GTK fallback, and Hyprland backend as user services because generic Linux does not expose the Nix packages to systemd automatically.
      (lib.mkIf (config.targets.genericLinux.enable && !cfg.configOnly) {
        xdg.portal.extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];

        systemd.user.packages = [
          pkgs.xdg-desktop-portal
          pkgs.xdg-desktop-portal-gtk
          config.wayland.windowManager.hyprland.finalPortalPackage
        ];
        # NOTE: Prepends the Home Manager profile to PATH for the systemd user manager and every service it starts.
        xdg.configFile."environment.d/envvars.conf".text = ''
          PATH="$HOME/.nix-profile/bin:$PATH"
        '';
      })
    ]
  );
}
