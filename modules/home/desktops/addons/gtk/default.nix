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
        tweaks = [ "black" ];
        accent = [ "mauve" ];
      };
    };

    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.catppuccin-papirus-folders;
    # };

    gtk4.theme = null; # Legacy default due to stateVersion
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
