{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
let
  cfg = config.roles.desktop.sway;
  modifier = "Mod4";
in
{
  options.roles.desktop.sway = {
    enable = lib.mkEnableOption "Enable Sway";

    package = lib.mkPackageOption pkgs "sway" {
      nullable = true;
    };

    autostart = mylib.mkOpt (lib.types.listOf lib.types.str) "autostart";
  };

  config = lib.mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs)
        rofimoji
        slurp
        ;
    };

    xdg.configFile."environment.d/envvars.conf".text = ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';

    programs.waybar.systemd.targets = lib.mkDefault [ "sway-session.target" ];

    wayland.windowManager.sway = {
      enable = true;

      inherit (cfg) package;

      systemd = {
        enable = true;
        variables = [ "--all" ];
        xdgAutostart = true;
      };

      extraSessionCommands = ''
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
      '';

      config = {
        inherit modifier;

        terminal = "alacritty";
        menu = "fuzzel";
        bars = [ ];

        gaps = {
          inner = 8;
          outer = 10;
        };

        window = {
          border = 3;
          titlebar = false;
          commands = [
            {
              command = "move scratchpad";
              criteria.title = "scratchy";
            }
            {
              command = "move scratchpad";
              criteria.class = ".*mumble.*";
            }
            {
              command = "move scratchpad";
              criteria.class = ".*keepassxc.*";
            }
          ];
        };

        input = {
          "type:keyboard" = {
            xkb_layout = "eu,de,de";
            xkb_variant = ",neo_qwertz,";
            repeat_rate = "45";
            repeat_delay = "150";
          };

          "type:pointer" = {
            accel_profile = "flat";
            pointer_accel = "1";
          };
        };

        startup = [
          { command = "alacritty -t scratchy"; }
          {
            command = "sleep 2 && chromium --profile-directory=Default --app-id=dlgohinmglaoopaiplliaecdpmnepmga";
          }
        ]
        ++ map (command: { inherit command; }) cfg.autostart;

        assigns = {
          "3" = [ { class = "^firefox$"; } ];
          "4" = [ { class = "^chromium-browser$"; } ];
        };

        floating.criteria = [
          { class = "^steam$"; }
          { class = "^.*nextcloud.*$"; }
        ];

        keybindings = lib.mkOptionDefault {
          "${modifier}+Return" = "exec alacritty";
          "${modifier}+e" = "exec fuzzel";
          "${modifier}+p" = "exec wlogout";
          "${modifier}+q" = "kill";

          "${modifier}+n" = "exec swaync-client -t";

          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+Shift+f" = "fullscreen toggle global";

          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";

          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";

          "${modifier}+t" = "layout toggle split";
          "${modifier}+u" = "floating toggle";

          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";

          "${modifier}+o" = "scratchpad show";
          "${modifier}+Shift+o" = "move scratchpad";

          "${modifier}+z" = "exec mumble rpc togglemute";
          "${modifier}+Shift+z" = "exec mumble rpc toggledeaf";

          "${modifier}+period" = "exec rofimoji --action copy type";
          "${modifier}+Shift+i" = "exec systemctl restart --user kanshi.service";

          "${modifier}+r" = "mode resize";
          "${modifier}+g" = "mode windows";
        };

        modes = {
          resize = {
            h = "resize shrink width 60 px";
            j = "resize grow height 60 px";
            k = "resize shrink height 60 px";
            l = "resize grow width 60 px";

            "Shift+h" = "resize shrink width 20 px";
            "Shift+j" = "resize grow height 20 px";
            "Shift+k" = "resize shrink height 20 px";
            "Shift+l" = "resize grow width 20 px";

            Return = "mode default";
            Escape = "mode default";
          };

          windows = {
            q = "move container to workspace number 1; mode default";
            w = "move container to workspace number 2; mode default";
            e = "move container to workspace number 3; mode default";
            r = "move container to workspace number 4; mode default";

            Return = "mode default";
            Escape = "mode default";
          };
        };
      };
    };
  };
}
