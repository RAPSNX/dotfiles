{lib, ...}: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 2000;
      format = lib.concatStrings [
        "$os"
        "$directory"
      ];

      fill.symbol = " ";

      line_break.disabled = true;

      directory = {
        truncate_to_repo = true;
        format = "[ﱮ $path ]($style)";
        style = "fg:text bg:#3B76F0";
      };

      palette = "catppuccin_macchiato";

      palettes.catppuccin_macchiato = {
        rosewater = "#f4dbd6";
        flamingo = "#f0c6c6";
        pink = "#f5bde6";
        mauve = "#c6a0f6";
        red = "#ed8796";
        maroon = "#ee99a0";
        peach = "#f5a97f";
        yellow = "#eed49f";
        green = "#a6da95";
        teal = "#8bd5ca";
        sky = "#91d7e3";
        sapphire = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
        text = "#cad3f5";
        subtext1 = "#b8c0e0";
        subtext0 = "#a5adcb";
        overlay2 = "#939ab7";
        overlay1 = "#8087a2";
        overlay0 = "#6e738d";
        surface2 = "#5b6078";
        surface1 = "#494d64";
        surface0 = "#363a4f";
        base = "#24273a";
        mantle = "#1e2030";
        crust = "#181926";
      };

      git_branch = {
        symbol = " ";
        format = "[ $symbol$branch(:$remote_branch) ]($style)";
        style = "fg:#1C3A5E bg:#FCF392";
      };

      git_metrics.disabled = false;

      nodejs = {
        format = "via [$symbol($version )]($style)";
        style = "yellow";
      };

      package = {
        disabled = true;
        format = "[$symbol$version]($style) ";
        display_private = true;
      };

      cmd_duration = {
        min_time = 2000;
        format = "[  $duration ]($style)";
        style = "white";
      };

      battery = {
        format = "[$symbol $percentage]($style) ";
        empty_symbol = "🪫";
        charging_symbol = "🔋";
        full_symbol = "🔋";
        display = [
          {
            threshold = 10;
            style = "red";
          }
        ];
      };

      custom = {
        git_config_email = {
          description = "Output the current git user's configured email address.";
          command = "git config user.email";
          format = "\n[$symbol(  $output)]($style)";
          when = "git rev-parse --is-inside-work-tree >/dev/null 2>&1";
          style = "text";
        };

        directory_separator_git = {
          description = "Output a styled separator right after the directory when inside a git repository.";
          command = "";
          format = "[](fg:#3B76F0 bg:#FCF392)";
          when = "git rev-parse --is-inside-work-tree >/dev/null 2>&1";
        };

        directory_separator_not_git = {
          description = "Output a styled separator right after the directory when NOT inside a git repository.";
          command = "";
          format = "[](fg:#3B76F0)";
          when = "! git rev-parse --is-inside-work-tree > /dev/null 2>&1";
        };
      };
    };
  };
}
