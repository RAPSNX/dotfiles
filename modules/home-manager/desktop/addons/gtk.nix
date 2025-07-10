{
  pkgs,
  lib,
  ...
}: {
  gtk = lib.mkForce {
    enable = true;

    theme = {
      name = "Catppuccin-GTK-Purple-Dark";
      package = pkgs.magnetic-catppuccin-gtk.override {
        tweaks = ["black"];
        accent = ["purple"];
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders;
    };

    gtk3.extraConfig = {
      gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-decoration-layout = "appmenu:none";
      gtk-button-images = 1;
      gtk-menu-images = 1;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-error-bell = 0;
      gtk-application-prefer-dark-theme = true;
      gtk-recent-files-max-age = 0;
      gtk-recent-files-limit = 0;
    };

    gtk4.extraConfig = {
      gtk-decoration-layout = "appmenu:none";
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-error-bell = 0;
      gtk-application-prefer-dark-theme = true;
      gtk-recent-files-max-age = 0;
    };
  };

  home = let
    name = "catppuccin-mocha-mauve-cursors";
    size = 28;
  in {
    pointerCursor = lib.mkForce {
      enable = true;
      inherit name size;
      package = pkgs.catppuccin-cursors.mochaMauve;
      gtk.enable = true;
    };

    sessionVariables = {
      XCURSOR_THEME = name;
      XCURSOR_SIZE = toString size;
      XCURSOR_PATH = "${pkgs.catppuccin-cursors.mochaMauve}/share/icons";
      HYPRCURSOR_THEME = name;
      # GTK_THEME = "catppuccin-mocha-mauve-standard+default";
    };
  };
}
