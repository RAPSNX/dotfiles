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

      hints.enabled = [
        # Hint to copy uuids
        {
          action = "Copy";
          hyperlinks = true;
          post_processing = true;
          # URL, email, ipv4/6, UUID, Git-Hash
          regex = ''(?:(?:https?://|ssh://)[^\\s<>"']+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}|(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)(?:\\.(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]?\\d)){3}|\\[(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}\\]|(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}|[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}|[0-9a-fA-F]{7,40})'';

          binding = {
            key = "H";
            mods = "Control|Shift";
          };
        }
      ];

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
          size = 12;
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
