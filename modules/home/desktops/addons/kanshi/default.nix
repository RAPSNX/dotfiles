{ lib, pkgs, ... }:
let
  wallpapers = builtins.concatStringsSep " " (
    map toString [
      ../../../../../extra/wallpapers/anime-city.jpg
      ../../../../../extra/wallpapers/gohan-supersaiyan.png
      ../../../../../extra/wallpapers/luffy-gear-5.jpg
      ../../../../../extra/wallpapers/minimal-space.jpg
      ../../../../../extra/wallpapers/one-piece-logo.jpg
    ]
  );

  shuffleWallpaper = pkgs.writeShellApplication {
    name = "shuffle-wallpaper";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.hyprland
    ];
    text = ''
      [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || exit 0
      sleep 1
      hyprctl hyprpaper wallpaper "$1,$(shuf -n 1 -e ${wallpapers}),cover"
    '';
  };

  randomWallpaper =
    monitor:
    lib.escapeShellArgs [
      "${shuffleWallpaper}/bin/shuffle-wallpaper"
      monitor
    ];
in
{
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";

    settings = [
      {
        output = {
          criteria = "eDP-1";
          position = "6000,0";
          mode = "1920x1200@60.00Hz";
        };
      }

      {
        profile = {
          name = "undocked";
          exec = randomWallpaper "eDP-1";
          outputs = [
            {
              criteria = "eDP-1";
            }
          ];
        };
      }

      {
        profile = {
          name = "office";
          exec = randomWallpaper "DP-1";
          outputs = [
            {
              # TODO: test this connector, may overload this config with all possible connectors
              criteria = "DP-1";
              mode = "3440x1440@99.98Hz";
              scale = 1.0;
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }

      # TODO: Add meeting room here

      {
        profile = {
          name = "home-firefly";
          exec = [
            (randomWallpaper "desc:Dell Inc. AW2725Q G2QC174")
            (randomWallpaper "desc:Samsung Electric Company LC27G7xT H4ZNC00167")
          ];
          outputs = [
            {
              criteria = "Dell Inc. AW2725Q G2QC174";
              scale = 1.5;
              position = "2560,0";
              mode = "3840x2160@239.99Hz";
            }
            {
              criteria = "Samsung Electric Company LC27G7xT H4ZNC00167";
              scale = 1.0;
              position = "0,0";
              mode = "2560x1440@239.96Hz";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        };
      }

      {
        profile = {
          name = "home";
          exec = [
            (randomWallpaper "desc:Dell Inc. AW2725Q G2QC174")
            (randomWallpaper "desc:Samsung Electric Company LC27G7xT H4ZNC00167")
          ];
          outputs = [
            {
              criteria = "Dell Inc. AW2725Q G2QC174";
              scale = 1.5;
              position = "2560,0";
              mode = "3840x2160@239.99Hz";
            }
            {
              criteria = "Samsung Electric Company LC27G7xT H4ZNC00167";
              scale = 1.0;
              position = "0,0";
              mode = "2560x1440@239.96Hz";
            }
          ];
        };
      }
    ];
  };
}
