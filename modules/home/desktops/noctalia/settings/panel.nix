{
  lib,
  systemLoad ? false,
}:
{
  control_center = {
    sidebar = "compact";
    hidden_tabs = [ "weather" ];
    shortcuts = [
      { type = "wifi"; }
      { type = "bluetooth"; }
      { type = "keyboard_layout"; }
      { type = "nightlight"; }
      { type = "notification"; }
      { type = "wallpaper"; }
      { type = "session"; }
    ];
  };

  bar.main = {
    position = "top";
    thickness = 42;
    background_opacity = 1.0;
    margin_edge = 0;
    margin_ends = 0;
    padding = 6;
    widget_spacing = 6;
    reserve_space = true;
    capsule = true;
    capsule_fill = "surface_variant";
    start = [
      "workspaces"
      "submap"
    ];
    center = [ "clock" ];
    end = [
      "tray"
    ]
    ++ (
      if systemLoad then
        [ "cpu_frequency" ]
      else
        [
          "cpu"
          "temp"
        ]
    )
    ++ lib.optionals systemLoad [
      "system_load"
      "gpu"
    ]
    ++ [
      "ram"
      "network"
      "brightness"
      "volume"
      "battery"
      "clipboard"
      "keyboard_layout"
      "session"
    ];
  };

  widget =
    lib.optionalAttrs systemLoad {
      cpu_frequency.type = "rapsnx/system-load:frequency";
      system_load.type = "rapsnx/system-load:load";
      gpu = {
        type = "sysmon";
        stat = "gpu_usage";
        show_value = true;
        visualization = "none";
      };
    }
    // {
      submap = {
        type = "rapsnx/hypr-submap:submap";
      };
      clock = {
        format = "{:%H:%M}";
        tooltip_format = "{:%A, %d %B %Y}";
      };
      workspaces = {
        style = "regular";
        show_labels = true;
        label_source = "id";
        focused_output_only = false;
        hide_when_empty = false;
        labels_only_when_occupied = false;
      };
      cpu = {
        show_value = true;
        show_glyph = true;
        visualization = "none";
      };
      temp = {
        show_value = true;
        show_glyph = true;
        visualization = "none";
      };
      ram = {
        show_value = true;
        show_glyph = true;
        visualization = "none";
      };
      network = {
        show_label = true;
        show_vpn_label = true;
      };
      volume.show_label = false;
      brightness.show_label = false;
      battery.show_label = false;
      tray = {
        drawer = false;
        hide_passive = false;
      };
      keyboard_layout = {
        hide_when_single_layout = false;
        show_glyph = true;
      };
    };
}
