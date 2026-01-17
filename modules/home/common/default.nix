{ lib, ... }:
{
  imports = [ ./roles.nix ];

  programs.home-manager.enable = true;
  xdg.enable = true;

  news = {
    display = "silent";
    json = lib.mkForce { };
    entries = lib.mkForce [ ];
  };

}
