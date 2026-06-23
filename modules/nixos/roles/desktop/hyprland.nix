{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.roles.desktop;
  catppuccinFlavor = "mocha";
  catppuccinAccent = "mauve";
  cursorTheme = {
    name = "catppuccin-${catppuccinFlavor}-${catppuccinAccent}-cursors";
    package = pkgs.catppuccin-cursors.mochaMauve;
  };
  gtkTheme = {
    name = "Catppuccin-GTK-Mauve-Dark";
    package = pkgs.magnetic-catppuccin-gtk.override {
      tweaks = [ "black" ];
      accent = [ catppuccinAccent ];
    };
  };
in
{
  config = lib.mkIf cfg {
    boot.plymouth.enable = true;

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = catppuccinFlavor;
      accent = catppuccinAccent;

      cursors.enable = true;
      plymouth.enable = true;
      tty.enable = true;
    };

    programs = {
      hyprland = {
        enable = true;
        withUWSM = false;
      };

      niri.enable = true;

      regreet = {
        enable = true;

        theme = gtkTheme;

        font = {
          name = "CaskaydiaCove Nerd Font";
          package = pkgs.nerd-fonts.caskaydia-cove;
          size = 15;
        };

        inherit cursorTheme;

        settings = {
          background = {
            path = ../../../../extra/wallpapers/minimal-space.jpg;
            fit = "Cover";
          };

          GTK.application_prefer_dark_theme = true;
        };

        extraCss = ''
          window {
            background-color: rgba(17, 17, 27, 0.92);
          }

          box#body {
            background-color: rgba(24, 24, 37, 0.78);
            border: 1px solid rgba(203, 166, 247, 0.35);
            border-radius: 12px;
            padding: 32px;
          }

          button {
            border-radius: 8px;
          }
        '';
      };
    };

    services.greetd = {
      enable = true;
      greeterManagesPlymouth = true;
    };
  };
}
