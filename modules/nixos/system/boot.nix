{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.boot;
in {
  options.hostConfiguration.boot = {
    armSupport = mkEnableOption "Enable arm cross-compiler support";
    supportedFilesystems = mkOption {
      type = with types; listOf str;
      default = [];
    };
  };

  config = {
    boot = {
      inherit (cfg) supportedFilesystems;
      binfmt.emulatedSystems = mkIf cfg.armSupport ["aarch64-linux"];

      consoleLogLevel = 3;
      initrd.verbose = false;

      kernelParams = [
        "quiet"
        "splash"
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
          # Recommended for systemd-boot '/boot', for grub its '/boot/efi'
          efiSysMountPoint = "/boot";
        };
      };
    };
    nix.settings.auto-optimise-store = true;
  };
}
