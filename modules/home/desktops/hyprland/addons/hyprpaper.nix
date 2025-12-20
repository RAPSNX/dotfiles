{
  self,
  ...
}:
{
  services.hyprpaper =
    let
      papersDir = "${self.outPath}/extra/wallpapers";
      papers = builtins.attrNames (builtins.readDir papersDir);
      paperPaths = map (paper: "${papersDir}/${paper}") papers;
    in
    {
      enable = true;
      settings = {
        splash = false;

        preload = paperPaths;

        wallpaper = map (p: ",${p}") paperPaths;
      };
    };
}
