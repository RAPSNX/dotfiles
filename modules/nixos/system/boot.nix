{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.boot;
in
{
  options.hostConfig.boot = {
    enable = lib.mkEnableOption "Enable install / config of bootloader";
    armSupport = lib.mkEnableOption "Enable arm cross-compiler support";
    supportedFilesystems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      inherit (cfg) supportedFilesystems;
      binfmt.emulatedSystems = lib.mkIf cfg.armSupport [ "aarch64-linux" ];

      consoleLogLevel = 3;
      initrd.verbose = false;

      kernelParams = [
        "quiet"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];

      loader = {
        timeout = 0;

        systemd-boot = {
          enable = true;
          configurationLimit = 15;
        };

        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
      };
    };
    nix.settings.auto-optimise-store = true;
  };
}
