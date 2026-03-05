{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hostConfig.roles.desktop;
in
{
  options.hostConfig.roles.desktop = mkEnableOption "Enable hyprland and desktop features.";

  config = mkIf cfg {
    programs = {
      thunar = {
        enable = true;
        plugins = with pkgs; [
          thunar-archive-plugin
          thunar-volman
        ];
      };
      xfconf.enable = true;
    };

    environment.systemPackages = [
      pkgs.file-roller
    ];

    services = {
      gvfs.enable = true; # virtual filesystems
      udisks2.enable = true; # automounts
    };
  };
}
