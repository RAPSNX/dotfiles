{
  control_center = {
    sidebar = "compact";
    hidden_tabs = [ "weather" ];
    shortcuts = [
      { type = "wifi"; }
      { type = "bluetooth"; }
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
      "cpu"
      "temp"
      "ram"
      "network"
      "brightness"
      "volume"
      "battery"
      "clipboard"
      "session"
    ];
  };

  widget = {
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
  };
}
