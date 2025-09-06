{lib, ...}:
with lib; {
  options.roles = {
    workdevice = mkEnableOption "Set device as workdevice, to enable special config.";
    useNixGL = mkEnableOption "Inject NixGL for all graphical dependend programms / binaries.";
    autostart = with types; mkOption {type = listOf str;};
  };
}
