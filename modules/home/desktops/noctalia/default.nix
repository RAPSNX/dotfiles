{
  lib,
  config,
  pkgs,
  inputs ? { },
  ...
}:
let
  cfg = config.roles.desktop.noctalia;
  wallpaperMigration = pkgs.writeShellApplication {
    name = "noctalia-wallpaper-migration";
    runtimeInputs = [
      config.programs.noctalia.package
      pkgs.coreutils
      pkgs.hyprland
      pkgs.jq
    ];
    text = ''
      marker="${config.xdg.stateHome}/noctalia/.wallpapers-migrated-v1"
      test -e "$marker" && exit 0
      mkdir -p "$(dirname "$marker")"

      attempt=1
      while ! noctalia msg wallpaper-get >/dev/null 2>&1; do
        if [ "$attempt" -ge 20 ]; then
          exit 1
        fi
        attempt=$((attempt + 1))
        sleep 1
      done

      noctalia msg wallpaper-set eDP-1 ${toString ../../../../extra/wallpapers/anime-city.jpg}
      noctalia msg wallpaper-set DP-1 ${toString ../../../../extra/wallpapers/gohan-supersaiyan.png}

      monitors="$(hyprctl -j monitors)"
      find_connector() {
        printf '%s' "$monitors" | jq -r --arg description "$1" 'first(.[] | select(.description == $description) | .name) // empty'
      }

      connector="$(find_connector 'Dell Inc. AW2725Q G2QC174')"
      if [ -n "$connector" ]; then
        noctalia msg wallpaper-set "$connector" ${toString ../../../../extra/wallpapers/luffy-gear-5.jpg}
      fi

      connector="$(find_connector 'Samsung Electric Company LC27G7xT H4ZNC00167')"
      if [ -n "$connector" ]; then
        noctalia msg wallpaper-set "$connector" ${toString ../../../../extra/wallpapers/one-piece-logo.jpg}
      fi

      touch "$marker"
    '';
  };
  sessionActions = [
    {
      action = "lock";
      shortcut = "1";
    }
    {
      action = "command";
      label = "Hibernate";
      glyph = "bed";
      command = "systemctl hibernate";
      shortcut = "2";
    }
    {
      action = "logout";
      shortcut = "3";
    }
    {
      action = "shutdown";
      shortcut = "4";
      variant = "destructive";
    }
    {
      action = "lock_and_suspend";
      label = "Suspend";
      glyph = "power";
      shortcut = "5";
    }
    {
      action = "reboot";
      shortcut = "6";
      variant = "destructive";
    }
  ]
  ++ lib.optionals cfg.windowsReboot.enable [
    {
      action = "command";
      label = "Reboot to Windows";
      glyph = "brand-windows";
      command = "sudo /run/current-system/sw/bin/reboot-windows";
      shortcut = "7";
      variant = "destructive";
    }
  ];
in
{
  options.roles.desktop.noctalia = {
    enable = lib.mkEnableOption "Enable the Noctalia desktop shell";

    windowsReboot.enable = lib.mkEnableOption "Add the Windows boot-loader action to Noctalia";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.noctalia-wallpaper-migration = {
      Unit = {
        Description = "Migrate Hyprpaper output assignments to Noctalia";
        After = [ "noctalia.service" ];
        Wants = [ "noctalia.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe wallpaperMigration;
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };

    programs.noctalia = {
      enable = true;
      package = lib.mkDefault (
        if inputs ? noctalia && inputs.noctalia ? packages then
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        else
          pkgs.noctalia
      );
      systemd.enable = true;
      settings = {
        accessibility.ui_scale = 1.0;

        shell = {
          font_family = "CaskaydiaCove Nerd Font";
          time_format = "{:%H:%M}";
          date_format = "%A, %x";
          setup_wizard_enabled = false;
          polkit_agent = true;
          launch_apps_as_systemd_services = true;
          screen_time_enabled = true;
          clipboard_enabled = true;
          clipboard_history_max_entries = 100;
          clipboard_keep_from_closed_apps = true;
          clipboard_auto_paste = "auto";
          panel = {
            launcher_placement = "floating";
            clipboard_placement = "floating";
            control_center_placement = "attached";
            session_placement = "attached";
          };
          launcher = {
            categories = false;
            show_icons = true;
            show_app_origin_indicator = false;
            show_app_actions = false;
            compact = true;
            sort_by_usage = true;
            provider_prefix = "/";
            providers = {
              calculator = {
                prefix = "calc";
                global = true;
              };
              emoji.prefix = "emo";
              session = {
                prefix = "session";
                global = false;
              };
              wallpaper.prefix = "wall";
              windows.prefix = "win";
            };
          };
          screenshot = {
            save_to_file = true;
            directory = "~/Pictures";
            copy_to_clipboard = true;
            freeze_screen = true;
          };
          session = {
            grid = true;
            grid_columns = 3;
            show_shortcuts = true;
            actions = sessionActions;
          };
          greeter_sync.auto_sync = cfg.windowsReboot.enable;
        };

        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };

        wallpaper = {
          enabled = true;
          fill_mode = "crop";
          directory = "${config.home.homeDirectory}/.local/share/wallpapers";
          default.path = toString ../../../../extra/wallpapers/minimal-space.jpg;
        };

        notification = {
          enable_daemon = true;
          position = "top_right";
          layer = "top";
          offset_x = 10;
          offset_y = 10;
          history_retention_hours = 0;
        };

        lockscreen = {
          enabled = true;
          lock_before_suspend = true;
          blurred_desktop = true;
          blur_intensity = 0.5;
          tint_intensity = 0.3;
        };

        idle = {
          pre_action_fade_seconds = 2.0;
          behavior = {
            lock = {
              timeout = 300;
              action = "lock";
              enabled = true;
            };
            screen-off = {
              timeout = 3600;
              action = "screen_off";
              enabled = true;
            };
          };
        };

        osd = {
          position = "top_center";
          kinds = {
            volume = true;
            volume_output = true;
            volume_input = true;
            brightness = true;
            wifi = true;
            bluetooth = true;
            dnd = true;
          };
        };

        system.monitor.enabled = true;
        calendar.enabled = true;
        nightlight = {
          enabled = true;
          temperature_day = 6500;
          temperature_night = 4000;
        };
        location = {
          custom_schedule = true;
          sunset = "22:00";
          sunrise = "06:30";
        };
        dock.enabled = false;

        control_center = {
          sidebar = "compact";
          hidden_tabs = [ "weather" ];
          shortcuts = [
            { type = "wifi"; }
            { type = "bluetooth"; }
            { type = "nightlight"; }
            { type = "notification"; }
            { type = "wallpaper"; }
            { type = "session"; }
          ];
        };

        bar.main = {
          position = "top";
          thickness = 42;
          background_opacity = 1.0;
          margin_edge = 0;
          margin_ends = 0;
          padding = 6;
          widget_spacing = 6;
          reserve_space = true;
          capsule = true;
          capsule_fill = "surface_variant";
          start = [
            "workspaces"
          ];
          center = [ "clock" ];
          end = [
            "tray"
            "cpu"
            "temp"
            "ram"
            "network"
            "brightness"
            "volume"
            "battery"
            "clipboard"
            "session"
          ];
        };

        widget = {
          clock = {
            format = "{:%H:%M}";
            tooltip_format = "{:%A, %d %B %Y}";
          };
          workspaces = {
            style = "regular";
            show_labels = true;
            label_source = "id";
            focused_output_only = false;
            hide_when_empty = false;
            labels_only_when_occupied = false;
          };
          cpu = {
            show_value = true;
            show_glyph = true;
            visualization = "none";
          };
          temp = {
            show_value = true;
            show_glyph = true;
            visualization = "none";
          };
          ram = {
            show_value = true;
            show_glyph = true;
            visualization = "none";
          };
          network = {
            show_label = true;
            show_vpn_label = true;
          };
          volume.show_label = false;
          brightness.show_label = false;
          battery.show_label = false;
          tray = {
            drawer = false;
            hide_passive = false;
          };
        };
      };
    };
  };
}
