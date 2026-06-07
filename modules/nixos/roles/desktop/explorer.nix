{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.roles.desktop;
in
{
  options.hostConfig.roles.desktop = lib.mkEnableOption "Enable hyprland and desktop features.";

  config = lib.mkIf cfg {
    programs = {
      thunar = {
        enable = true;
        plugins = lib.attrValues {
          inherit (pkgs) thunar-archive-plugin thunar-volman;
        };
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
