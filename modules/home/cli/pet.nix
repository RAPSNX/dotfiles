{
  lib,
  config,
  ...
}:
{
  programs.pet = {
    enable = true;
    settings = {
      General = lib.mkForce {
        snippetfile = "${config.home.homeDirectory}/Projects/rapsnx/dotfiles/extra/snippet.toml";
        selectcmd = "fzf --ansi";
        color = true;
      };
    };
  };
}
