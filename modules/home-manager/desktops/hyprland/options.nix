{
  pkgs,
  lib,
  ...
}:
with lib; {
  options.roles.desktop.hyprland = {
    enable = mkEnableOption "Enable hyprland";

    package = mkPackageOption pkgs "hyprland" {
      nullable = true;
    };

    hyprlock = {
      enable = mkEnableOption "Enable hyprlock";
    };

    hypridle = {
      enable = mkEnableOption "Enable hypridle";
      cmd = mkOption {type = types.str;};
    };
  };
}
