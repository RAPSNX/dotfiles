{ config, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        autoFetch = true;
        diffRenderers = [
          {
            colorArg = "always";
            command = "${config.programs.delta.package}/bin/delta --dark --paging=never";
          }
        ];
      };
    };
  };
}
