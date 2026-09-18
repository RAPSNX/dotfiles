{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";
    stateVersion = "22.05";

    packages = [
      inputs.neonix.packages.${pkgs.stdenv.hostPlatform.system}.mini
      pkgs.nerd-fonts.caskaydia-cove
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  roles = {
    email = "raphael.groemmer@digits.schwarz";
  };

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };

    starship = {
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

        nix_shell.format = "[$symbol]($style)";

        character = {
          success_symbol = "[ ➜](bold fg:green) ";
          error_symbol = "[ ✗](bold fg:red) ";
        };
      };
    };
  };
}
