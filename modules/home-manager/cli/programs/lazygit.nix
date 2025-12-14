{config, ...}: {
  catppuccin.lazygit.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        autoFetch = true;
        pagers = [
          {
            colorArg = "always";
            pager = "${config.programs.delta.package}/bin/delta --dark --paging=never";
          }
        ];
      };
    };
  };
}
