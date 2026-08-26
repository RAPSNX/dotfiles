{ lib, ... }:
{
  programs.home-manager.enable = true;
  xdg.enable = true;

  catppuccin = {
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
