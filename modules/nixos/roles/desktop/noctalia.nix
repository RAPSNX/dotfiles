{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.roles.desktop;
in
{
  config = lib.mkIf cfg {
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        keyboard = {
          layout = "eu,de,de";
          variant = ",neo_qwertz,";
        };
        idle.timeout = 300;
      };
    };

    security.pam.services.greetd.enableGnomeKeyring = true;

    services.greetd = {
      enable = true;
      settings = {
        terminal.vt = 1;
        default_session = {
          command = lib.mkForce "${config.services.displayManager.noctalia-greeter.package}/bin/noctalia-greeter-session --";
          user = "greeter";
        };
      };
    };
  };
}
