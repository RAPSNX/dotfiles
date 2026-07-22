{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.roles.niri;
in
{
  options.hostConfig.roles.niri = lib.mkEnableOption "Enable niri as a display manager session.";

  config = lib.mkIf cfg {
    programs.niri.enable = true;
  };
}
