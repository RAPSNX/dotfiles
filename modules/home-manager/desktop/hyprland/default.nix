{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.roles.desktop.hyprland;
in {
  imports = [
    # Addons
    ./addons/hyprpaper.nix
    ./addons/hyprlock.nix
  ];

  options.roles.desktop.hyprland = {
    enable = mkEnableOption "Enable hyprland";
    configOnly = mkEnableOption "Provision only config files";
    hyprlock = mkEnableOption "Enable hyprlock & hypridle";
  };

  config = mkIf cfg.enable {
    catppuccin.hyprland.enable = true;

    wayland.windowManager.hyprland = let
      windows = import ./config/windows.nix;
      programs = import ./config/programs.nix;
      workspaces = import ./config/workspaces.nix;
    in {
      enable = true;
      package =
        if cfg.configOnly
        then null
        else pkgs.hyprland;
      systemd.enable = false; # Disable for uswm

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

        input = {
          kb_layout = "eu";
          repeat_rate = 45;
          repeat_delay = 150;
          accel_profile = "flat";
          sensitivity = 1; # -1.0 - 1.0, 0 means no modification.
        };

        decoration = import ./config/decoration.nix;
        exec-once = import ./config/autostart.nix {inherit pkgs;} ++ config.roles.autostart;

        inherit (windows) windowrule windowrulev2;
        inherit (workspaces) workspace;

        bind = windows.bind ++ programs.bind ++ workspaces.bind;

        source = [
          "~/.config/hypr/monitors.conf"
          "~/.config/hypr/workspaces.conf"
        ];
      };
      inherit (windows) extraConfig;
    };

    home.packages = with pkgs; [
      hyprland-qtutils
    ];

    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = ["hyprland" "gtk"];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    # environment.d defines environment variables for the user session, beyond shell level.
    # It is processed by `systemd --user`, basically after login.
    # - Adds the nix-store-path to the `PATH` globally for user applications.
    # - Adds XDG_DATA_DIRS globally to allign GTK themes and config dirs session wide.
    xdg.configFile."environment.d/envvars.conf".text = ''
      PATH="$HOME/.nix-profile/bin:$PATH"
      XDG_DATA_DIRS=${concatStringsSep ":" [
        "${config.home.homeDirectory}/.nix-profile/share"
        "/usr/share"
        "/nix/var/nix/profiles/default/share"
      ]}
    '';
  };
}
