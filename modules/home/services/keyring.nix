{ pkgs, lib, ... }:
{
  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
    ];
  };
  home.packages = lib.attrValues {
    inherit (pkgs) gcr seahorse;
  };
}
