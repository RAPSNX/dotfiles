{ config, ... }:

let
  variables = config.wayland.windowManager.hyprland.systemd.variables;

  required = [
    "WAYLAND_DISPLAY"
    "HYPRLAND_INSTANCE_SIGNATURE"
    "XDG_CURRENT_DESKTOP"
    "XDG_SESSION_TYPE"
  ];
in
{
  assertions = [
    {
      assertion = !(builtins.elem "PATH" variables);
      message = "Hyprland must not import PATH into the systemd user environment; PATH is managed through environment.d.";
    }
    {
      assertion = builtins.all (v: builtins.elem v variables) required;
      message = "Hyprland systemd variables are missing required session environment variables.";
    }
  ];
}
