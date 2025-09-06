{pkgs, ...}: {
  home.packages = with pkgs; [
    pavucontrol
    spek
  ];
}
