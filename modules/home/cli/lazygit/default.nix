{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        openLink = "xdg-open {{link}} >/dev/null 2>&1 &";
      };
      git = {
        autoFetch = true;
        pagers = [
          {
            externalDiffCommand = "${pkgs.difftastic}/bin/difft --color=always";
          }
        ];
      };
    };
  };
}
