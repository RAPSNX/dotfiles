{lib, ...}: {
  catppuccin.starship.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 2000;

      # saubere Powerline-Form mit Catppuccin-Farben
      format = lib.concatStrings [
        "[](fg:blue)"
        "$os"
        "[](fg:blue bg:teal)"
        "$directory"
        "[](fg:teal bg:yellow)"
        "$git_branch$git_status"
        "[](fg:yellow bg:base)"
        "$git_metrics"

        "$fill"

        "$cmd_duration"

        "$line_break"

        "$character"
      ];

      right_format = lib.concatStrings [];

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

      git_status = {
        conflicted = "=$count";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        untracked = "?$count";
        stashed = "\\$$count";
        modified = "!$count";
        staged = "+$count";
        renamed = "»$count";
        deleted = "✘$count";
        format = "[ $all_status ]($style)";
        style = "fg:base bg:yellow";
      };

      git_metrics = {
        disabled = false;
        # format = "[ +$added ]($added_style)[-$deleted ]($deleted_style)";
        added_style = "fg:green bg:base";
        deleted_style = "fg:red bg:base";
      };

      cmd_duration = {
        format = "[$duration ]($style) ";
      };

      character = {
        success_symbol = "[ ➜](bold fg:green) ";
        error_symbol = "[ ✗](bold fg:red) ";
      };
    };
  };
}
