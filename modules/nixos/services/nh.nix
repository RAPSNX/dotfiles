{
  config,
  lib,
  ...
}:
let
  cfg = config.hostConfig.services.nh;
in
{
  options.hostConfig.services.nh = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable nh and its automatic store cleanup.";
  };

  config = lib.mkIf cfg {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 5 --keep-since 5d";
      flake = "/home/rap/Projects/rapsnx/dotfiles";
    };
  };
}
