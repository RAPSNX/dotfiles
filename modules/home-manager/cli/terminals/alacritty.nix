{
  pkgs,
  config,
  ...
}: let
  inherit (config.roles) useNixGL;
in {
  catppuccin.alacritty.enable = true;
  programs.alacritty = {
    enable = true;
    package =
      if useNixGL
      then config.lib.nixGL.wrap pkgs.alacritty
      else pkgs.alacritty;
    settings = {
      terminal.shell.program = "zsh";
      env.TERM = "xterm-256color";

      selection = {
        save_to_clipboard = true;
      };
      window = {
        padding = {
          x = 3;
          y = 3;
        };
      };

      font = let
        fontname = "CaskaydiaCove Nerd Font";
      in {
        normal = {
          family = fontname;
          style = "SemiBold";
        };
        bold = {
          family = fontname;
          style = "Bold";
        };
        italic = {
          family = fontname;
          style = "Italic";
        };
        size = 13;
      };

      mouse.bindings = [
        {
          mouse = "Right";
          action = "Paste";
        }
      ];
    };
  };
}
