{
  lib,
  pkgs,
  ...
}: {
  catppuccin.starship.enable = true;
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 2000;

      format = lib.concatStrings [
        "$os"
        "$directory"

        "$git_branch"
        "$git_commit"

        "$character"
      ];

      right_format = lib.concatStrings [
        "$kubernetes"
        "$shlvl"
      ];

      os.disabled = false;

      line_break.disabled = true;

      directory = {
        truncate_to_repo = true;
        truncation_length = 5;
        format = "[ $path ]($style)";
        style = "fg:text bg:#3B76F0";
      };

      kubernetes = {
        disabled = false;
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };

      shlvl.disabled = false;

      git_branch = {
        symbol = " ";
        ignore_branches = ["HEAD"];
      };

      git_commit = {
        tag_disabled = false;
        tag_symbol = " 🏷 ";
        format = "[$tag]($style) ";
      };

      package = {
        disabled = true;
        format = "[$symbol$version]($style) ";
        display_private = true;
      };

      fill.symbol = " ";

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
        proxy = {
          description = "The currently used proxy";
          when = ''test -n "$http_proxy"'';
          command = ''test -n "$PROXY_TARGET" && echo "$PROXY_TARGET" || echo "<unknown>"'';
          shell = ["${lib.getExe pkgs.bash}" "--noprofile" "--norc"];
          symbol = "🔀 ";
          style = "bright-yellow";
          format = "[$symbol$output]($style) ";
        };
        openstack = {
          description = "The currently targeted openstack tenant";
          when = ''test -n "$OS_TENANT_NAME"'';
          command = ''echo "$OS_TENANT_NAME"'';
          shell = ["${lib.getExe pkgs.bash}" "--noprofile" "--norc"];
          symbol = "☁️ ";
          style = "bright-red";
          format = "[$symbol$output]($style) ";
        };
      };
    };
  };
}
