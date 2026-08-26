{
  config,
  lib,
  ...
}:
let
  cfg = config.hostConfig.cli.starship;
in
{
  options.hostConfig.cli.starship.enable = lib.mkEnableOption "the remote Starship prompt";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
        palette = "catppuccin_mocha";

        palettes.catppuccin_mocha = {
          base = "#1e1e2e";
          red = "#f38ba8";
          teal = "#94e2d5";
          yellow = "#f9e2af";
          green = "#a6e3a1";
        };

        format = lib.concatStrings [
          "[](fg:red)"
          "$hostname"
          "[](fg:red bg:teal)"
          "$directory"
          "[](fg:teal bg:base)"
          "$git_branch"
          "$nix_shell"
          "$line_break"
          "$character"
        ];

        hostname = {
          ssh_only = false;
          format = "[ $hostname ]($style)";
          style = "bg:red fg:base";
        };

        directory = {
          truncation_symbol = "…/";
          truncation_length = 4;
          format = "[ $path ]($style)";
          style = "fg:base bg:teal";
        };

        git_branch = {
          format = "([ $symbol$branch ]($style))";
          symbol = "  ";
          style = "fg:yellow";
        };

        nix_shell = {
          format = "[$symbol]($style)";
        };

        character = {
          success_symbol = "[ ➜](bold fg:green) ";
          error_symbol = "[ ✗](bold fg:red) ";
        };
      };
    };
  };
}
