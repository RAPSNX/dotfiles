{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.roles.desktop.hyprland;

  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua { };

  mkLuaArgs = args: { _args = args; };
  mkBind =
    keys: dispatcher: options:
    mkLuaArgs (
      [
        keys
        (mkLuaInline dispatcher)
      ]
      ++ lib.optional (options != { }) options
    );
  mkSequence = dispatchers: ''
    function()
    ${lib.concatMapStrings (dispatcher: "  hl.dispatch(${dispatcher})\n") dispatchers}end
  '';

  dispatcher = {
    exec = command: "hl.dsp.exec_cmd(${toLua command})";
    focus = direction: "hl.dsp.focus({ direction = ${toLua direction} })";
    fullscreen = options: "hl.dsp.window.fullscreen(${toLua options})";
    layout = message: "hl.dsp.layout(${toLua message})";
    moveWindow = options: "hl.dsp.window.move(${toLua options})";
    resizeWindow = options: "hl.dsp.window.resize(${toLua options})";
    selectWorkspace = workspace: "hl.dsp.focus({ workspace = ${toLua workspace} })";
    submap = name: "hl.dsp.submap(${toLua name})";
    toggleFloating = "hl.dsp.window.float({ action = \"toggle\" })";
    toggleSpecialWorkspace = workspace: "hl.dsp.workspace.toggle_special(${toLua workspace})";
  };

  clearNotification = dispatcher.exec "noctalia msg notification-clear-active";
  mkModeBind =
    keys: mode: command:
    mkBind keys
      (mkSequence [
        (dispatcher.exec command)
        (dispatcher.submap mode)
      ])
      {
        description = "Enter ${mode} mode";
      };
  mkSubmapBind =
    keys: command: description:
    mkBind keys
      (mkSequence [
        (dispatcher.exec command)
        clearNotification
      ])
      {
        inherit description;
      };

  toggleFirefox = pkgs.writeShellScriptBin "toggle-firefox" ''
    #!/usr/bin/env bash
    set -euo pipefail

    CLASS="firefox"
    DEDICATED_WS="3"

    current_ws="$(hyprctl activeworkspace -j | jq -r '.id')"

    firefox_on_current="$(
      hyprctl clients -j | jq -r --arg class "$CLASS" --argjson ws "$current_ws" '
        any(.[]; (.class | ascii_downcase) == $class and .workspace.id == $ws)
      '
    )"

    if [[ "$firefox_on_current" == "true" ]]; then
      hyprctl dispatch movetoworkspacesilent "$DEDICATED_WS,class:$CLASS"
    else
      hyprctl dispatch movetoworkspace "+0,class:$CLASS"
    fi
  '';
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.bind = [
        # Common
        (mkBind "SUPER + RETURN" (dispatcher.exec "alacritty") { description = "Open terminal"; })
        (mkBind "SUPER + E" (dispatcher.exec "noctalia msg panel-toggle launcher") {
          description = "Open launcher";
        })
        (mkBind "SUPER + P" (dispatcher.exec "noctalia msg panel-toggle session") {
          description = "Open session panel";
        })
        (mkBind "SUPER + Q" "hl.dsp.window.close()" { description = "Close active window"; })
        (mkBind "ALT + TAB" (dispatcher.exec "noctalia msg window-switcher") {
          description = "Open window switcher";
        })

        # Window actions
        (mkBind "SUPER + F" (dispatcher.fullscreen { mode = 1; }) { description = "Toggle fullscreen"; })
        (mkBind "SUPER + SHIFT + F" (dispatcher.fullscreen { }) { description = "Toggle full fullscreen"; })

        # Movement
        (mkBind "SUPER + H" (dispatcher.focus "left") { description = "Focus left"; })
        (mkBind "SUPER + J" (dispatcher.focus "down") { description = "Focus down"; })
        (mkBind "SUPER + K" (dispatcher.focus "up") { description = "Focus up"; })
        (mkBind "SUPER + L" (dispatcher.focus "right") { description = "Focus right"; })

        # Window movement
        (mkBind "SUPER + SHIFT + H" (dispatcher.moveWindow { direction = "left"; }) {
          description = "Move window left";
        })
        (mkBind "SUPER + SHIFT + J" (dispatcher.moveWindow { direction = "down"; }) {
          description = "Move window down";
        })
        (mkBind "SUPER + SHIFT + K" (dispatcher.moveWindow { direction = "up"; }) {
          description = "Move window up";
        })
        (mkBind "SUPER + SHIFT + L" (dispatcher.moveWindow { direction = "right"; }) {
          description = "Move window right";
        })

        # Layout toggle
        (mkBind "SUPER + T" (dispatcher.layout "togglesplit") { description = "Toggle split"; })
        (mkBind "SUPER + U" dispatcher.toggleFloating { description = "Toggle floating"; })

        # Workspace selection
        (mkBind "SUPER + 1" (dispatcher.selectWorkspace "1") { description = "Focus workspace 1"; })
        (mkBind "SUPER + 2" (dispatcher.selectWorkspace "2") { description = "Focus workspace 2"; })
        (mkBind "SUPER + 3" (dispatcher.selectWorkspace "3") { description = "Focus workspace 3"; })
        (mkBind "SUPER + 4" (dispatcher.selectWorkspace "4") { description = "Focus workspace 4"; })
        (mkBind "SUPER + 5" (dispatcher.selectWorkspace "5") { description = "Focus workspace 5"; })

        # Special workspaces
        (mkBind "SUPER + O" (dispatcher.toggleSpecialWorkspace "scratchy") {
          description = "Toggle scratch workspace";
        })
        (mkBind "SUPER + M" (dispatcher.toggleSpecialWorkspace "aux") {
          description = "Toggle auxiliary workspace";
        })
        (mkBind "SUPER + SHIFT + O" (dispatcher.moveWindow { workspace = "special:scratchy"; }) {
          description = "Move window to scratch workspace";
        })
        (mkBind "SUPER + SHIFT + M" (dispatcher.moveWindow { workspace = "special:aux"; }) {
          description = "Move window to auxiliary workspace";
        })

        # Programs
        (mkBind "SUPER + Z" (dispatcher.exec "mumble rpc togglemute") {
          description = "Toggle Mumble mute";
        })
        (mkBind "SUPER + SHIFT + Z" (dispatcher.exec "mumble rpc toggledeaf") {
          description = "Toggle Mumble deafen";
        })
        (mkBind "SUPER + period" (dispatcher.exec "noctalia msg panel-toggle launcher /emo") {
          description = "Open emoji launcher";
        })
        (mkBind "SUPER + SHIFT + I" (dispatcher.exec "systemctl restart --user kanshi.service") {
          description = "Restart Kanshi";
        })

        # Mouse
        (mkBind "SUPER + mouse:272" "hl.dsp.window.drag()" {
          mouse = true;
          description = "Move window with mouse";
        })
        (mkBind "SUPER + mouse:273" "hl.dsp.window.resize()" {
          mouse = true;
          description = "Resize window with mouse";
        })

        # Modes
        (mkModeBind "SUPER + N" "noctalia"
          "noctalia msg notification-show 'MODE: NOCTALIA' '[n] Notifications  [m] Monitor  [c] Calendar  [s] Region  [S] Full  [a] Annotate'"
        )
        (mkModeBind "SUPER + R" "resize"
          "noctalia msg notification-show 'MODE: RESIZE' '[H/J/K/L] Resize  [Shift+H/J/K/L] Fine  [Esc/Enter] Exit'"
        )
        (mkModeBind "SUPER + G" "windows"
          "noctalia msg notification-show 'MODE: WINDOWS' '[Q/W/E/R] Move to WS  [B] Toggle Firefox  [Esc/Enter] Exit'"
        )
      ];

      submaps = {
        noctalia = {
          onDispatch = "reset";
          settings.bind = [
            (mkSubmapBind "N" "noctalia msg panel-toggle control-center notifications" "Open notifications")
            (mkSubmapBind "M" "noctalia msg panel-toggle control-center monitor" "Open system monitor")
            (mkSubmapBind "C" "noctalia msg panel-toggle control-center calendar" "Open calendar")
            (mkSubmapBind "S" "noctalia msg screenshot-region" "Capture region")
            (mkSubmapBind "SHIFT + S" "noctalia msg screenshot-fullscreen" "Capture screen")
            (mkSubmapBind "A"
              "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | ${lib.getExe pkgs.satty} --filename -"
              "Capture annotated region"
            )
            (mkSubmapBind "RETURN" "noctalia msg notification-clear-active" "Exit mode")
            (mkSubmapBind "ESCAPE" "noctalia msg notification-clear-active" "Exit mode")
          ];
        };

        resize = {
          onDispatch = "reset";
          settings.bind = [
            (mkBind "H" (dispatcher.resizeWindow {
              x = -60;
              y = 0;
              relative = true;
            }) { description = "Resize left"; })
            (mkBind "J" (dispatcher.resizeWindow {
              x = 0;
              y = 60;
              relative = true;
            }) { description = "Resize down"; })
            (mkBind "K" (dispatcher.resizeWindow {
              x = 0;
              y = -60;
              relative = true;
            }) { description = "Resize up"; })
            (mkBind "L" (dispatcher.resizeWindow {
              x = 60;
              y = 0;
              relative = true;
            }) { description = "Resize right"; })
            (mkBind "SHIFT + H" (dispatcher.resizeWindow {
              x = -20;
              y = 0;
              relative = true;
            }) { description = "Resize left finely"; })
            (mkBind "SHIFT + J" (dispatcher.resizeWindow {
              x = 0;
              y = 20;
              relative = true;
            }) { description = "Resize down finely"; })
            (mkBind "SHIFT + K" (dispatcher.resizeWindow {
              x = 0;
              y = -20;
              relative = true;
            }) { description = "Resize up finely"; })
            (mkBind "SHIFT + L" (dispatcher.resizeWindow {
              x = 20;
              y = 0;
              relative = true;
            }) { description = "Resize right finely"; })
            (mkSubmapBind "RETURN" "noctalia msg notification-clear-active" "Exit mode")
            (mkSubmapBind "ESCAPE" "noctalia msg notification-clear-active" "Exit mode")
          ];
        };

        windows = {
          onDispatch = "reset";
          settings.bind = [
            (mkBind "Q" (mkSequence [
              (dispatcher.moveWindow { workspace = "1"; })
              clearNotification
            ]) { description = "Move window to workspace 1"; })
            (mkBind "W" (mkSequence [
              (dispatcher.moveWindow { workspace = "2"; })
              clearNotification
            ]) { description = "Move window to workspace 2"; })
            (mkBind "E" (mkSequence [
              (dispatcher.moveWindow { workspace = "3"; })
              clearNotification
            ]) { description = "Move window to workspace 3"; })
            (mkBind "R" (mkSequence [
              (dispatcher.moveWindow { workspace = "4"; })
              clearNotification
            ]) { description = "Move window to workspace 4"; })
            (mkSubmapBind "B" (lib.getExe toggleFirefox) "Toggle Firefox")
            (mkSubmapBind "RETURN" "noctalia msg notification-clear-active" "Exit mode")
            (mkSubmapBind "ESCAPE" "noctalia msg notification-clear-active" "Exit mode")
          ];
        };
      };
    };
  };
}
