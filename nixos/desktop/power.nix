{
  powerManagement.enable = false;
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
  };
}
