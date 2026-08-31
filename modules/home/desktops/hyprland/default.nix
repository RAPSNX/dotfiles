{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;

  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua { };

  mkLuaArgs = args: { _args = args; };
  autostart = [
    "[ workspace special:scratchy silent ] alacritty -t scratchy"
    "[ workspace special:aux silent ] sleep 2 && chromium --profile-directory=Default --app-id=dlgohinmglaoopaiplliaecdpmnepmga"
  ]
  ++ cfg.autostart;
  startHook = mkLuaInline ''
    function()
    ${lib.concatMapStrings (command: "  hl.exec_cmd(${toLua command})\n") autostart}end
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

    autostart = mylib.mkOpt (lib.types.listOf lib.types.str) "autostart";
  };

  imports = [ ./keybinds.nix ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        catppuccin.hyprland.enable = false;

        xdg.configFile."environment.d/envvars.conf".text = ''
          PATH="$HOME/.nix-profile/bin:$PATH"
        '';

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "lua";

          inherit (cfg) package;

          systemd.enable = true;

          xdph.settings.screencopy = {
            cursor_mode = 2;
            force_shm = true;
            allow_token_by_default = true;
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
