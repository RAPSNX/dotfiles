{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with lib;
with mylib;
with pkgs;
let
  cfg = config.roles.desktop.hyprland;
in
{
  options.roles.desktop.hyprland = {
    enable = mkEnableOption "Enable hyprland";

    package = mkPackageOption pkgs "hyprland" {
      nullable = true;
    };

    hyprlock = {
      enable = mkEnableOption "Enable hyprlock";
    };

    hypridle = {
      enable = mkEnableOption "Enable hypridle";
      cmd = mkOption { type = types.str; };
    };
  };

  imports = [
    ./addons/hypridle.nix
    ./addons/hyprlock.nix
  ];

  config = lib.mkIf cfg.enable {

    home.packages = [
      hyprland-qtutils
      slurp
    ];

    # environment.d defines environment variables for the user session, beyond shell level.
    # It is processed by `systemd --user`, basically after login.
    xdg.configFile."environment.d/envvars.conf".text = ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';

    catppuccin.hyprland.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      inherit (cfg) package;

      settings = {
        general = {
          gaps_in = 8;
          gaps_out = 10;
          border_size = 3;
        };

        # Auto tile new windows
        dwindle = {
          preserve_split = "yes";
          special_scale_factor = 0.8;
        };

        input = {
          kb_layout = "eu,de,de";
          kb_variant = ",neo_qwertz,";
          repeat_rate = 45;
          repeat_delay = 150;
          accel_profile = "flat";
          sensitivity = 1; # -1.0 - 1.0, 0 means no modification.
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
          active_opacity = 0.98;
          inactive_opacity = 0.85;
        };

        # Autostart
        exec-once = [
          # TODO: check if needed?
          # "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "[ workspace special:scratchy silent ] alacritty -t scratchy"
        ];

        workspace = with config.roles.desktop.monitors; [
          # Special
          "special:scratchy"
          "special:aux"

          # Pinning
          "1,monitor:, monitor:desc:${main},default:true"
          "2,monitor:, monitor:desc:${main},"
          "3,monitor:, monitor:desc:${main},"

          "4,monitor:, monitor:desc:${left},default:true"
          "5,monitor:, monitor:desc:${left},"
          "6,monitor:, monitor:desc:${left},"

          # TODO: Check if this works in office
          "1,monitor:, monitor:DP-8,default:true"
          "2,monitor:, monitor:DP-8"
          "3,monitor:, monitor:DP-8"

          "4,monitor:, monitor:DP-9,default:true"
          "5,monitor:, monitor:DP-9"
          "6,monitor:, monitor:DP-9"
        ];

        windowrule = [
          "match:class ^(firefox)$, workspace 4"
          "match:class ^(chromium-browser)$, workspace 5"

          "match:class ^(.*mumble.*)$, workspace special:aux silent"
          "match:class ^(.*keepassxc.*)$, workspace special:aux silent"

          # Force floating
          "match:class steam, float yes"
          "match:class ^(.*nextcloud.*)$, float yes"
        ];

        bind = import ./keybinds.nix;

        extraConfig = ''
          # Resize mouse
          bindm = SUPER, mouse:272, movewindow
          bindm = SUPER, mouse:273, resizewindow

          # Resize mode
          bind = SUPER, R, submap, resize
          submap = resize
            bind = , H, resizeactive, -60 0
            bind = , J, resizeactive, 0 60
            bind = , K, resizeactive, 0 -60
            bind = , L, resizeactive, 60 0

            bind = SHIFT, H, resizeactive, -20 0
            bind = SHIFT, J, resizeactive, 0 20
            bind = SHIFT, K, resizeactive, 0 -20
            bind = SHIFT, L, resizeactive, 20 0

            bind = , return, submap, reset
            bind = , escape, submap, reset
          submap = reset
        '';
      };
    };

  };
}
