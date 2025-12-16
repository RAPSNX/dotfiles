{ pkgs, ... }:
{
  catppuccin.alacritty.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  fonts.fontconfig.enable = true;

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
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

      font =
        let
          fontname = "CaskaydiaCove Nerd Font";
        in
        {
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
