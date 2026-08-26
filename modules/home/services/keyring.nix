{
  config,
  lib,
  pkgs,
  ...
}:
{
  # On NixOS, PAM starts and unlocks the login keyring. On generic Linux hosts,
  # Home Manager still needs to provide the user service.
  services.gnome-keyring.enable = lib.mkForce config.targets.genericLinux.enable;

  home.packages = builtins.attrValues {
    inherit (pkgs) gcr seahorse;
  };
}
