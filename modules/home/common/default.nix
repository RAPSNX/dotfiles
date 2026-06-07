{ lib, ... }:
{
  imports = [ ./roles.nix ];

  programs.home-manager.enable = true;
  xdg.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  news = {
    display = "silent";
    json = lib.mkForce { };
    entries = lib.mkForce [ ];
  };
}
