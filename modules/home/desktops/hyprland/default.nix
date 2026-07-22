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

    hyprlock = {
      enable = lib.mkEnableOption "Enable hyprlock";
    };

    hypridle = {
      enable = lib.mkEnableOption "Enable hypridle";
      cmd = mylib.mkOpt lib.types.str "Path to binary";
    };
  };

  imports = [
    ./addons/hypridle.nix
    ./addons/hyprlock.nix
    ./keybinds.nix
  ];

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        catppuccin.hyprland.enable = false;
        catppuccin.hyprlock.enable = false;

        services.hyprpaper.enable = true;

        # xdg.configFile."hypr/xdph.conf".text = ''
        #   screencopy {
        #       force_shm = true
        #   }
        # '';

        home.packages = builtins.attrValues {
          inherit (pkgs)
            rofimoji
            slurp
            ;
        };

        xdg.configFile."environment.d/envvars.conf".text = ''
          PATH="$HOME/.nix-profile/bin:$PATH"
        '';

        programs.waybar.systemd.targets = lib.mkDefault [ "hyprland-session.target" ];

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "hyprlang";

          inherit (cfg) package;

          systemd = {
            enable = true;
            variables = [ "--all" ];
          };

          settings = {
            env = [
              "XDG_CURRENT_DESKTOP,Hyprland"
              "XDG_SESSION_DESKTOP,Hyprland"
              "XDG_SESSION_TYPE,wayland"
            ];

            general = {
              gaps_in = 8;
              gaps_out = 10;
              border_size = 3;
            };

            source = [
              "${config.xdg.configHome}/hypr/monitors.conf"
              "${config.xdg.configHome}/hypr/workspaces.conf"
            ];

            dwindle = {
              preserve_split = "yes";
              special_scale_factor = 0.8;
            };

            input = {
              kb_layout = "eu,de,de";
              kb_variant = ",neo_qwertz,";
              repeat_rate = 40;
              repeat_delay = 250;
              accel_profile = "flat";
              sensitivity = 1;
            };

            xwayland = {
              force_zero_scaling = true;
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

            exec-once = [
              "[ workspace special:scratchy silent ] alacritty -t scratchy"
              # todoist app
              "[ workspace special:aux silent ] sleep 2 && chromium --profile-directory=Default --app-id=dlgohinmglaoopaiplliaecdpmnepmga"
            ]
            ++ cfg.autostart;

            windowrule = [
              "match:class ^(firefox)$, workspace 3"
              "match:class ^(chromium-browser)$, workspace 4"

              "match:class ^(.*mumble.*)$, workspace special:aux silent"
              "match:class ^(.*keepassxc.*)$, workspace special:aux silent"

              "match:class steam, float yes"
              "match:class ^(.*nextcloud.*)$, float yes"
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
