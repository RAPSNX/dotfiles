{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 5 --keep-since 5d";
    flake = "/home/rap/Projects/rgroemmer/dotfiles";
  };
}
