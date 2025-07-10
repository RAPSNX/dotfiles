{config, ...}: {
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
      # TODO: check, how to disable tabs in lazygit
      # os = {
      #   editPreset = "nvim-remote";
      #   edit = ''[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})'';
      #   editAtLine = ''[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" &&  nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>")'';
      #   openDirInEditor = ''[ -z "$NVIM" ] && (nvim -- {{dir}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{dir}})'';
      # };
    };
  };
}
