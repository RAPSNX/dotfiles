{
  pkgs,
  inputs,
  ...
}:
let
  path = "${inputs.self.outPath}/extra/wallpapers";
  shuffle-wallpaper = pkgs.writeShellScriptBin "shuffle-wallpaper" ''
      #!/usr/bin/env bash

      WALLPAPER_PATH="${path}"
      readarray -t MONITORS < <(hyprctl monitors -j | jq -r '.[].name')
      COUNT=''${#MONITORS[@]}

      readarray -t PAPERS < <(find "$WALLPAPER_PATH" -type f | shuf -n "$COUNT")

      for ((i = 0; i < COUNT; i++)); do
          MON="''${MONITORS[i]}"
          PAPER="''${PAPERS[i]}"
          hyprctl hyprpaper preload "$PAPER"
          hyprctl hyprpaper wallpaper "$MON,$PAPER"
          hyprctl hyprpaper unload unused
    done
  '';
in
{
  home.packages = [ shuffle-wallpaper ];

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
    };
  };

  systemd.user.services.set-wallpaper = {
    Unit = {
      Description = "set-wallpaper";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${shuffle-wallpaper}/bin/shuffle-wallpaper";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
