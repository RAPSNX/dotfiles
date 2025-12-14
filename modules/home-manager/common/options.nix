{lib, ...}:
with lib; {
  options.roles = {
    workdevice = mkEnableOption "Set device as workdevice, to enable special config.";
    autostart = with types; mkOption {type = listOf str;};
  };
}
