{ pkgs, ... }:
{
  home.packages = [
    pkgs.libsForQt5.qtstyleplugin-kvantum
    (pkgs.catppuccin-kvantum.override {
      accent = "mauve";
      variant = "mocha";
    })
  ];

  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".source =
    (pkgs.formats.ini { }).generate "kvantum.kvconfig"
      { General.theme = "Catppuccin-Mocha-Mauve"; };
}
