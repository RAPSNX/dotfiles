{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.roles.desktop;
in {
  config = mkIf cfg {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    services.greetd = {
      enable = true;

      settings.default_session.command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --theme 'border=magenta;text=cyan;prompt=green;time=red;action=blue;button=yellow;container=black;input=red' \
          --cmd '${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop'
      '';
    };
  };
}
