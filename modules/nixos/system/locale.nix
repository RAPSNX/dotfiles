{lib, ...}: {
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.utf8";
      LC_IDENTIFICATION = "de_DE.utf8";
      LC_MEASUREMENT = "de_DE.utf8";
      LC_MONETARY = "de_DE.utf8";
      LC_NAME = "de_DE.utf8";
      LC_NUMERIC = "de_DE.utf8";
      LC_PAPER = "de_DE.utf8";
      LC_TELEPHONE = "de_DE.utf8";
      LC_TIME = "de_DE.utf8";
    };
  };
  time.timeZone = "Europe/Berlin";
  time.hardwareClockInLocalTime = true;

  console = {
    font = "ter-v32b";
    keyMap = "us";
  };
}
