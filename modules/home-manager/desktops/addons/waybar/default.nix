{
  catppuccin.waybar.enable = true;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = builtins.fromJSON "${builtins.readFile ./waybar.json} ";
    };
    style = "${builtins.readFile ./waybar.css}";
  };
}
