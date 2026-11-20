{ lib, ... }:
{
  imports = [ ./roles.nix ];

  programs.home-manager.enable = true;
  xdg.enable = true;
  xdg.autostart.enable = true;

  catppuccin = {
    cache.enable = true;
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  news = {
    display = "silent";
    json = lib.mkForce { };
    entries = lib.mkForce [ ];
  };
}
