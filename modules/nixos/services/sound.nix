{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.services.sound;
in
{
  options.hostConfig.services.sound = lib.mkEnableOption "Enable sound.";

  config = lib.mkIf cfg {
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };
  };
}
