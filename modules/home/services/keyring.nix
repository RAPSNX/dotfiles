{ pkgs, ... }:
{
  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
    ];
  };
  home.packages = builtins.attrValues {
    inherit (pkgs) gcr seahorse;
  };
}
