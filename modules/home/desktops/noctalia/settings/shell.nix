{
  sessionActions,
  windowsReboot,
}:
{
  font_family = "FiraCode Nerd Font";
  time_format = "{:%H:%M}";
  date_format = "%A, %x";
  setup_wizard_enabled = false;
  polkit_agent = true;
  launch_apps_as_systemd_services = true;
  screen_time_enabled = true;
  clipboard_enabled = true;
  clipboard_history_max_entries = 100;
  clipboard_keep_from_closed_apps = true;
  clipboard_auto_paste = "auto";
  panel = {
    launcher_placement = "floating";
    clipboard_placement = "floating";
    control_center_placement = "attached";
    session_placement = "attached";
  };
  launcher = {
    categories = false;
    show_icons = true;
    show_app_origin_indicator = false;
    show_app_actions = false;
    compact = true;
    sort_by_usage = true;
    provider_prefix = "/";
    providers = {
      calculator = {
        prefix = "calc";
        global = true;
      };
      emoji.prefix = "emo ";
      session = {
        prefix = "session";
        global = false;
      };
      wallpaper.prefix = "wall";
      windows.prefix = "win";
    };
  };
  screenshot = {
    save_to_file = true;
    directory = "~/Pictures";
    copy_to_clipboard = true;
    freeze_screen = true;
  };
  session = {
    grid = true;
    grid_columns = 3;
    show_shortcuts = true;
    actions = sessionActions;
  };
  greeter_sync.auto_sync = windowsReboot;
}
