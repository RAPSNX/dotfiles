{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  fonts.fontconfig.enable = true;
}
