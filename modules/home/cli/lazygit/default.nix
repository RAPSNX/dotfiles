{ config, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        openLink = "xdg-open {{link}} >/dev/null 2>&1 &";
      };
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
