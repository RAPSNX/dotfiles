{config, ...}: {
  catppuccin.lazygit.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        autoFetch = true;
        paging = {
          colorArg = "always";
          pager = "${config.programs.git.delta.package}/bin/delta --dark --paging=never";
        };
      };
    };
  };
}
