{
  lib,
  config,
  self,
  ...
}:
let
  cfg = config.roles.desktop.hyprland.hyprpaper;
  papersDir = "${self.outPath}/extra/wallpapers";
  papers = builtins.attrNames (builtins.readDir papersDir);
  paperPaths = map (paper: "${papersDir}/${paper}") papers;
in
{
  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        preload = paperPaths;
        wallpaper = map (p: ",${p}") paperPaths;
      };
    };
  };
}
