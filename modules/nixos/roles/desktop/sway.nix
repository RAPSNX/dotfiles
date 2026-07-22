{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.roles.sway;
in
{
  options.hostConfig.roles.sway = lib.mkEnableOption "Enable sway as a display manager session.";

  config = lib.mkIf cfg {
    programs.sway.enable = true;
  };
}
