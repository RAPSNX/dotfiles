{ pkgs, lib, ... }:
{
  services.kanshi =
    let
      hyprctl = lib.getExe' pkgs.hyprland "hyprctl";

      # Pins Hyprland workspaces to monitors.
      # Args: primary matcher, optional secondary matcher.
      # Writes workspace config for hyprland, reloads it, and sets focus.
      workspaceSetup = pkgs.writeShellScriptBin "workspaceSetup" ''
        set -euo pipefail

        monitors="$(${hyprctl} monitors -j)"

        match_monitor() {
          ${lib.getExe pkgs.jq} -r --arg matcher "$1" '
            [.[] | select(.description | test($matcher)) | .name][0]' <<< "$monitors"
        }

        primary="$(match_monitor "''${1:?missing primary monitor matcher}")"
        secondary="$(match_monitor "''${2:-$1}")"

        cat > "$HOME/.config/hypr/workspaces.conf" <<EOF
        workspace = 1, monitor:$primary, default:true
        workspace = 2, monitor:$primary
        workspace = 3, monitor:$secondary, default:true
        workspace = 4, monitor:$secondary
        EOF

        ${hyprctl} reload

        ${hyprctl} dispatch moveworkspacetomonitor "1 $primary"
        ${hyprctl} dispatch moveworkspacetomonitor "2 $primary"
        ${hyprctl} dispatch moveworkspacetomonitor "3 $secondary"
        ${hyprctl} dispatch moveworkspacetomonitor "4 $secondary"

        ${hyprctl} dispatch focusmonitor "$primary"
        ${hyprctl} dispatch workspace 1
        systemctl --user restart waybar.service
      '';

      # mkExec collects all outputs and creates args out of it, the workspaceSetup script only takes the first two.
      mkExec =
        outputs:
        "${lib.getExe workspaceSetup} ${lib.escapeShellArgs (map (output: output.criteria) outputs)}";

      mkProfile =
        { name, outputs }:
        {
          profile = {
            inherit name outputs;
            exec = mkExec outputs;
          };
        };
    in
    {
      enable = true;
      systemdTarget = "hyprland-session.target";

      settings = [
        {
          output = {
            criteria = "eDP-1";
            position = "0,0";
            mode = "1920x1200@60.00Hz";
          };
        }

        {
          # Default profile, without exec
          profile = {
            name = "undocked";
            outputs = [
              {
                criteria = "eDP-1";
              }
            ];
          };
        }

        (mkProfile {
          name = "office";
          outputs = [
            {
              criteria = "HP Inc. HP 534pm *";
              mode = "3440x1440@99.98Hz";
              scale = 1.0;
            }
            {
              criteria = "*";
            }
          ];
        })

        # TODO: Add meeting room here

        (mkProfile {
          name = "home-firefly";
          outputs = [
            {
              criteria = "Dell Inc. AW2725Q G2QC174";
              scale = 1.5;
              position = "2560,0";
              mode = "3840x2160@239.99Hz";
            }
            {
              criteria = "Samsung Electric Company LC27G7xT H4ZNC00167";
              scale = 1.0;
              position = "0,0";
              mode = "2560x1440@239.96Hz";
            }
            {
              criteria = "*";
            }
          ];
        })

        (mkProfile {
          name = "home";
          outputs = [
            {
              criteria = "Dell Inc. AW2725Q G2QC174";
              scale = 1.5;
              position = "2560,0";
              mode = "3840x2160@239.99Hz";
            }
            {
              criteria = "Samsung Electric Company LC27G7xT H4ZNC00167";
              scale = 1.0;
              position = "0,0";
              mode = "2560x1440@239.96Hz";
            }
          ];
        })
      ];
    };
}
