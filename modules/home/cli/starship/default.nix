{
  lib,
  ...
}:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 500;
      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
        text = "#cdd6f4";
        blue = "#89b4fa";
        lavender = "#b4befe";
        sapphire = "#74c7ec";
        sky = "#89dceb";
        teal = "#94e2d5";
        green = "#a6e3a1";
        yellow = "#f9e2af";
        peach = "#fab387";
        maroon = "#eba0ac";
        red = "#f38ba8";
        mauve = "#cba6f7";
        pink = "#f5c2e7";
      };

      # saubere Powerline-Form mit Catppuccin-Farben
      format = lib.concatStrings [
        "[](fg:blue)"
        "$os"
        "[](fg:blue bg:teal)"
        "$directory"
        "[](fg:teal bg:yellow)"
        "$git_branch"
        "[](fg:yellow bg:base)"
        "$git_status"
        "$nix_shell"

        "$line_break"

        "$character"
      ];

      right_format = lib.concatStrings [
        "$kubernetes"
        "\${env_var.OS_TENANT_NAME}"
        "\${env_var.http_proxy}"
        "$cmd_duration"
      ];

      os = {
        disabled = false;
        # nur Farbe, Rest macht das Theme
        style = "bg:blue fg:base";
      };

      directory = {
        truncation_symbol = "…/";
        truncation_length = 5;
        format = "[ $path ]($style)";
        style = "fg:base bg:teal";
      };

      fill = {
        symbol = " ";
        style = "bright-black";
      };

      git_branch = {
        format = "[ $symbol$branch(:$remote_branch) ]($style)";
        symbol = "  ";
        style = "fg:base bg:yellow";
      };

      kubernetes = {
        disabled = false;
        detect_env_vars = [ "KUBECONFIG" ];
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };

      git_status = {
        conflicted = "[=$count ](bold fg:red)";
        ahead = "[⇡$count ](bold fg:blue)";
        behind = "[⇣$count ](bold fg:peach)";
        diverged = "[⇕⇡$ahead_count⇣$behind_count ](bold fg:red)";
        untracked = "[?$count ](bold fg:sapphire)";
        stashed = "[📦$count ](bold fg:mauve)";
        modified = "[!$count ](bold fg:yellow)";
        staged = "[+$count ](bold fg:green)";
        renamed = "[»$count ](bold fg:teal)";
        deleted = "[✘$count ](bold fg:red)";
        format = "([ $all_status$ahead_behind]($style))";
        style = "fg:base";
      };

      git_metrics = {
        disabled = true;
      };

      nix_shell = {
        format = "[$symbol]($style)";
      };

      shlvl = {
        disabled = false;
      };

      cmd_duration = {
        format = "[$duration ]($style) ";
      };

      character = {
        success_symbol = "[ ➜](bold fg:green) ";
        error_symbol = "[ ✗](bold fg:red) ";
      };

      os.symbols = {
        Alpine = " ";
        Debian = " ";
        Fedora = " ";
        Linux = " ";
        NixOS = " ";
        Raspbian = " ";
        Ubuntu = " ";
      };

      env_var = {
        http_proxy = {
          variable = "http_proxy";
          symbol = "🔀 ";
          style = "bright-yellow";
          format = "[$symbol$env_value]($style) ";
        };
        OS_TENANT_NAME = {
          variable = "OS_TENANT_NAME";
          symbol = "☁️ ";
          style = "bright-red";
          format = "[$symbol$env_value]($style) ";
        };
      };
    };
  };
}
