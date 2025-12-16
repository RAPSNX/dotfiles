{
  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      # Defaults for new installations (`atuin default-config`)
      sync.records = true;
      enter_accept = true;

      style = "compact";
      inline_height = 20;
      show_tabs = false;
      secrets_filter = false;

      sync_address = "https://atuin.app.rockwolf.eu";
    };
  };
}
