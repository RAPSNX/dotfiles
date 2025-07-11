{pkgs, ...}: {
  imports = [
    ./addons
  ];

  catppuccin.ghostty.enable = true;
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      font-size = 12;
      font-family = "CaskaydiaCove Nerd Font";
    };
  };
}
