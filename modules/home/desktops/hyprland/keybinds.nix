{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;

  toggleFirefox = pkgs.writeShellScriptBin "toggleFirefox" ''
    #!/usr/bin/env bash
    set -euo pipefail

    CLASS="firefox"
    DEDICATED_WS="3"

    current_ws="$(hyprctl activeworkspace -j | jq -r '.id')"

    firefox_on_current="$(hyprctl clients -j | jq -r --arg class "$CLASS" --argjson ws "$current_ws" '
      any(.[]; (.class | ascii_downcase) == $class and .workspace.id == $ws)
    ')"

    if [[ "$firefox_on_current" == "true" ]]; then
      hyprctl dispatch movetoworkspacesilent "$DEDICATED_WS,class:$CLASS"
    else
      hyprctl dispatch movetoworkspace "+0,class:$CLASS"
    fi
  '';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ toggleFirefox ];

    wayland.windowManager.hyprland = {
      extraLuaFiles.bindings = ./bindings.lua;
    };
  };
}
