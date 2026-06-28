{
  lib,
  config,
  ...
}:
let
  cfg = config.hostConfig.roles.desktop;
in
{
  imports = [
    ./hyprland.nix
    ./fonts.nix
    ./power.nix
    ./explorer.nix
  ];

  options.hostConfig.roles.desktop = lib.mkEnableOption "Enable desktop features.";

  config = lib.mkIf cfg {
    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      greetd.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
  };
}
