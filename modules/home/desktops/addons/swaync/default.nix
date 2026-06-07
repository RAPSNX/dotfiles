{
  # swaynotificationcenter like "dunst"
  services.swaync = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./swaync.json);
    # style = builtins.readFile ./swaync.css;
  };
}
