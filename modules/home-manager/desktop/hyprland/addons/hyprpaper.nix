{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.roles.desktop.hyprland;

  primary = (elemAt cfg.monitors 1).ID;
  secondary = (elemAt cfg.monitors 0).ID;

  path = "~/.config/wallpapers";

  shuffle-wallpaper = pkgs.writeShellScriptBin "shuffle-wallpaper" ''
    #!/usr/bin/env bash

    SHUFFLE1="$(ls ${path} | shuf -n1)"
    hyprctl hyprpaper preload "${path}/$SHUFFLE1"
    hyprctl hyprpaper wallpaper "${primary},${path}/$SHUFFLE1"
    SHUFFLE2="$(ls ${path} | grep -v "$SHUFFLE1" | shuf -n1)"
    hyprctl hyprpaper preload "${path}/$SHUFFLE2"
    hyprctl hyprpaper wallpaper "${secondary},${path}/$SHUFFLE2"

    hyprctl hyprpaper unload unused

  '';
in {
  config = {
    home.file.".config/wallpapers" = {
      source = ./wallpapers;
      recursive = true;
    };
    home.packages = [shuffle-wallpaper];

    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
      };
    };
  };
}
