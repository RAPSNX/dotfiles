{ pkgs, ... }:
let
  generalBinding = {
    key = "H";
    mods = "Control";
  };

  platformBinding = {
    key = "K";
    mods = "Control";
  };

  # Keep these as one alternation per mode. This prevents overlapping matches
  # such as a hostname inside a URL from producing duplicate hint labels.
  generalRegex = ''(?:ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh://|ftp://)[^[:space:]<>"\x27{}^\x60]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|(?-u:\b)(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(?:\.(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}(?-u:\b)|\[(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}\]|(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}|(?-u:\b)[0-9A-Fa-f]{8}(?:-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}(?-u:\b)|(?-u:\b)[0-9A-Fa-f]{32}(?-u:\b)|(?:~|\.{1,2})/[^[:space:]<>"\x27\x60]+|/(?:home|etc|var|tmp|usr|opt|run|dev|mnt|root)/[^[:space:]<>"\x27\x60]+|(?-u:\b)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,}(?-u:\b)|(?-u:\b)[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+:[^[:space:]<>"\x27\x60]+'';

  platformRegex = ''(?-u:\b)shoot-[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:-[a-z0-9](?:[-a-z0-9]*[a-z0-9])?)+(?-u:\b)|(?-u:\b)(?:source-)?shoot--[a-z0-9](?:[-a-z0-9]*[a-z0-9])?(?:--[a-z0-9](?:[-a-z0-9]*[a-z0-9])?){1,2}(?-u:\b)|(?-u:\b)[a-z0-9](?:[a-z0-9._-]*[a-z0-9])*(?::[A-Za-z0-9._-]+|@sha256:[0-9a-fA-F]{64})(?-u:\b)|(?-u:\b)[a-z0-9](?:[a-z0-9._-]*[a-z0-9])?(?:/[a-z0-9](?:[a-z0-9._-]*[a-z0-9])?)+(?::[A-Za-z0-9._-]+|@sha256:[0-9a-fA-F]{64})(?-u:\b)|(?:context|ctx|namespace|ns)[=:][[:space:]]*[A-Za-z0-9][A-Za-z0-9._-]*|(?:--context|--namespace|-n)[=:[:space:]]*[A-Za-z0-9][A-Za-z0-9._-]*|(?:[a-z0-9](?:[-a-z0-9]*[a-z0-9])?\.)+[a-z0-9](?:[-a-z0-9]*[a-z0-9])?/[A-Za-z0-9][A-Za-z0-9_.-]*(?:[=:][[:space:]]*[A-Za-z0-9_.:/-]+)?|(?-u:\b)[A-Za-z][A-Za-z0-9_.-]*=[A-Za-z0-9_.:/-]+(?-u:\b)|(?-u:\b)[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.svc(?:\.cluster\.local)?(?-u:\b)|(?:\[[0-9A-Fa-f:]+\]|(?:[A-Za-z0-9-]+\.)+[A-Za-z0-9-]+|(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(?:\.(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}):[0-9]{1,5}'';

in
{
  home.packages = [
    pkgs.nerd-fonts.caskaydia-cove
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
        # General copy hints: links, network identifiers, paths, and Git
        # artifacts without matching arbitrary hyphenated words.
        {
          action = "Copy";
          binding = generalBinding;
          hyperlinks = true;
          post_processing = true;
          regex = generalRegex;
        }

        # Kubernetes and Gardener copy hints: images, Shoot technical IDs,
        # selectors, annotations, contexts, namespaces, and endpoints.
        {
          action = "Copy";
          binding = platformBinding;
          post_processing = true;
          regex = platformRegex;
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
