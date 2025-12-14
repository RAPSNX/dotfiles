{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
with lib;
with mylib;
let
  cfg = config.roles.desktop.hyprland;
in
{
  imports = [
    # Addons
    ./addons/hyprpaper.nix
    ./addons/hyprlock.nix
    ./addons/hypridle.nix
  ];

  options.roles.desktop.hyprland = {
    enable = mkEnableOption "Enable hyprland";
    package = mkPackageOption pkgs "hyprland" {nullable = true;};

    hyprlock = {
      enable = mkEnableOption "Enable hyprlock";
    };
    hypridle = {
      enable = mkEnableOption "Enable hypridle";
      cmd = mkOpt types.str "Path to locking binary";
    };
  };

  config =
    let
      windows = import ./config/windows.nix;
      programs = import ./config/programs.nix;
      workspaces = import ./config/workspaces.nix;
    in
    mkIf cfg.enable {
      catppuccin.hyprland.enable = true;

      wayland.windowManager.hyprland = {
        enable = true;
        inherit (cfg) package;
        systemd.enable = false; # Disable for uswm

        # portalPackage = pkgs.xdg-desktop-portal-wlr;
        inherit (windows) extraConfig;

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

          xwayland = {
            force_zero_scaling = true;
          };

          monitor = [
            "DP-8,highres,auto,auto"
            "DP-9,highres,auto,auto"

            "DP-2,highres,0x0,auto"
            "DP-1,highres,auto,auto"
          ];

          input = {
            kb_layout = "eu";
            repeat_rate = 45;
            repeat_delay = 150;
            accel_profile = "flat";
            sensitivity = 1; # -1.0 - 1.0, 0 means no modification.
          };

          decoration = import ./config/decoration.nix;

          exec-once = [
            "uwsm app -- ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            "[ workspace special:scratchy silent ] alacritty -t scratchy"
            "sleep 5 && hyprctl dispatch closewindow class:ZSTray"
            "sleep 5 && uwsm app -- mumble --tray"
          ];

          inherit (windows) windowrule windowrulev2;
          inherit (workspaces) workspace;

          bind = windows.bind ++ programs.bind ++ workspaces.bind;

          # source = [
          #   "~/.config/hypr/monitors.conf"
          #   "~/.config/hypr/workspaces.conf"
          # ];
        };
      };

      home.packages = with pkgs; [
        hyprland-qtutils
        slurp
      ];

      xdg.portal = {
        enable = true;
        config = {
          common = {
            default = [
              "hyprland"
              "gtk"
            ];
          };
        };
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-hyprland
        ];
      };

      # environment.d defines environment variables for the user session, beyond shell level.
      # It is processed by `systemd --user`, basically after login.
      xdg.configFile."environment.d/envvars.conf".text = ''
        PATH="$HOME/.nix-profile/bin:$PATH"
      '';
    };
}
