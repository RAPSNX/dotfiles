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
    ./niri.nix
    ./sway.nix
    ./fonts.nix
    ./power.nix
    ./explorer.nix
  ];

  config = lib.mkIf cfg {
    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      greetd.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
  };
}
