{
  pkgs,
  lib,
  ...
}:
{
  gtk = {
    enable = true;
    colorScheme = "dark";

    theme = {
      name = "Catppuccin-GTK-Mauve-Dark";
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ "mauve" ];
      };
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.theme = null; # Legacy default due to stateVersion
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home =
    let
      name = "catppuccin-mocha-mauve-cursors";
      size = 35;
    in
    {
      pointerCursor = lib.mkForce {
        enable = true;
        inherit name size;
        package = pkgs.catppuccin-cursors.mochaMauve;
        gtk.enable = true;
      };
    };
}
