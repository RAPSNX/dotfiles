{ config, lib, ... }:
{
  config = lib.mkIf (!config.hostConfig.roles.desktop) {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      shellInit = ''
        eval "$(fzf --zsh)"
      '';
    };
  };
}
