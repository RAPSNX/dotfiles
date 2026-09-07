{
  lib,
  config,
  pkgs,
  inputs ? { },
  ...
}:
let
  cfg = config.roles.desktop.noctalia;
  inherit (cfg) externalLockCommand;
  hyprctl =
    if config.roles.desktop.hyprland.configOnly then
      "/usr/bin/hyprctl"
    else
      lib.getExe' pkgs.hyprland "hyprctl";

  lockAction =
    if externalLockCommand == null then
      {
        action = "lock";
        label = "Lock";
        glyph = "lock";
        shortcut = "1";
      }
    else
      {
        action = "command";
        label = "Lock";
        glyph = "lock";
        command = externalLockCommand;
        shortcut = "1";
      };

  sessionActions = [
    lockAction
    {
      action = "command";
      label = "Log Out";
      glyph = "logout";
      command = "${hyprctl} dispatch exec ${lib.getExe pkgs.hyprshutdown}";
      shortcut = "2";
    }
    {
      action = "shutdown";
      shortcut = "3";
      variant = "destructive";
    }
    {
      action = "reboot";
      shortcut = "4";
      variant = "destructive";
    }
  ]
  ++ lib.optionals cfg.windowsReboot.enable [
    {
      action = "command";
      label = "Reboot to Windows";
      glyph = "brand-windows";
      command = "sudo /run/current-system/sw/bin/reboot-windows";
      shortcut = "5";
      variant = "destructive";
    }
  ];
in
{
  options.roles.desktop.noctalia = {
    enable = lib.mkEnableOption "Enable the Noctalia desktop shell";

    windowsReboot.enable = lib.mkEnableOption "Add the Windows boot-loader action to Noctalia";

    polkitAgent = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Whether to enable Noctalia's built-in polkit authentication agent.";
    };

    externalLockCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/usr/bin/swaylock --daemonize";
      description = "External screen-lock command. When unset, Noctalia uses its native lock screen.";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      configFile = {
        "autostart/nm-applet.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Network
          Hidden=true
        '';

        "autostart/blueman.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Blueman
          Hidden=true
        '';

        "autostart/update-notifier.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Update Notifier
          Hidden=true
        '';
      };

      dataFile = {
        "noctalia/plugins/hypr-submap/plugin.toml".source = ./plugins/hypr-submap/plugin.toml;
        "noctalia/plugins/hypr-submap/widget.luau".source = ./plugins/hypr-submap/widget.luau;
      };
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

        plugins = {
          enabled = [ "rapsnx/hypr-submap" ];
        };

        shell = import ./settings/shell.nix {
          inherit sessionActions;
          inherit (cfg) polkitAgent;
          windowsReboot = cfg.windowsReboot.enable;
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
          enabled = externalLockCommand == null;
        }
        // lib.optionalAttrs (externalLockCommand == null) {
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
              action = if externalLockCommand == null then "lock" else "custom";
            }
            // lib.optionalAttrs (externalLockCommand != null) {
              command = externalLockCommand;
            }
            // {
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
            keyboard_layout = true;
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

      }
      // import ./settings/panel.nix;
    };

    # NOTE:
    # Make Noctalia's tray watcher ready before XDG autostart starts.
    # Noctalia owns org.kde.StatusNotifierWatcher on Hyprland, so Type=dbus makes
    # systemd consider the service ready only after the tray watcher is registered.
    # This prevents tray applications from beeing racy.
    systemd.user.services.noctalia = {
      Unit = {
        PartOf = lib.mkForce [ "hyprland-session.target" ];
        After = lib.mkForce [ ];
        Before = [ "graphical-session-pre.target" ];
      };

      Service = {
        Type = "dbus";
        BusName = "org.kde.StatusNotifierWatcher";
      };

      Install.WantedBy = lib.mkForce [ "graphical-session-pre.target" ];
    };
  };
}
