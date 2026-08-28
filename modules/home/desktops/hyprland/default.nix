{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;
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

    autostart = mylib.mkOpt (lib.types.listOf lib.types.str) "autostart";
  };

  imports = [ ./keybinds.nix ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        catppuccin.hyprland.enable = false;

        xdg.configFile."hypr/xdph.conf".text = ''
          screencopy {
              cursor_mode = 2
              force_shm = 1
              allow_token_by_default = 1
          }
        '';

        xdg.configFile."environment.d/envvars.conf".text = ''
          PATH="$HOME/.nix-profile/bin:$PATH"
        '';

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "lua";

          inherit (cfg) package;

          systemd = {
            enable = true;
            variables = [ "--all" ];
          };

          extraLuaFiles = {
            "settings" = ''
              -- Environment
              hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
              hl.env("XDG_SESSION_DESKTOP", "Hyprland")
              hl.env("XDG_SESSION_TYPE", "wayland")

              -- General, dwindle, input, xwayland, decoration configuration
              hl.config({
                general = {
                  gaps_in = 8,
                  gaps_out = 10,
                  border_size = 3,
                  ["col.active_border"] = "rgba(cba6f7ee) rgba(89b4faee) 45deg",
                  ["col.inactive_border"] = "rgba(585b70aa)",
                },
                dwindle = {
                  preserve_split = true,
                  special_scale_factor = 0.8,
                },
                input = {
                  kb_layout = "eu,de,de",
                  kb_variant = ",neo_qwertz,",
                  kb_options = "grp:alt_shift_toggle",
                  repeat_rate = 40,
                  repeat_delay = 250,
                  accel_profile = "flat",
                  sensitivity = 1,
                },
                xwayland = {
                  force_zero_scaling = true,
                },
                decoration = {
                  rounding = 5,
                  blur = {
                    enabled = true,
                    size = 3,
                    passes = 2,
                    ignore_opacity = true,
                    new_optimizations = true,
                  },
                },
              })
            '';

            "rules" = ''
              -- Workspaces
              hl.workspace("1, monitor:desc:Dell Inc. AW2725Q G2QC174, default:true")
              hl.workspace("2, monitor:desc:Dell Inc. AW2725Q G2QC174")
              hl.workspace("3, monitor:desc:Samsung Electric Company LC27G7xT H4ZNC00167, default:true")
              hl.workspace("4, monitor:desc:Samsung Electric Company LC27G7xT H4ZNC00167")

              -- Window rules
              hl.windowrule("match:class ^(firefox)$, workspace 3")
              hl.windowrule("match:class ^(chromium-browser)$, workspace 4")
              hl.windowrule("match:class ^(.*mumble.*)$, workspace special:aux silent")
              hl.windowrule("match:class ^(.*keepassxc.*)$, workspace special:aux silent")
              hl.windowrule("match:class steam, float yes")
              hl.windowrule("match:class ^(.*nextcloud.*)$, float yes")
            '';

            "autostart" = ''
              hl.exec_once("[ workspace special:scratchy silent ] alacritty -t scratchy")
              hl.exec_once("[ workspace special:aux silent ] sleep 2 && chromium --profile-directory=Default --app-id=dlgohinmglaoopaiplliaecdpmnepmga")
              ${lib.concatMapStringsSep "\n" (cmd: "hl.exec_once(\"${cmd}\")") cfg.autostart}
            '';
          };
        };
      }

      (lib.mkIf cfg.configOnly {
        wayland.windowManager.hyprland = {
          package = lib.mkForce null;
          portalPackage = lib.mkForce null;
        };

        xdg.portal.enable = lib.mkForce false;
      })
    ]
  );
}
