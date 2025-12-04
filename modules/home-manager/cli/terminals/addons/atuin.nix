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

      # TODO: update to new address
      sync_address = "https://atuin.taild68e9.ts.net";
    };
  };
}
