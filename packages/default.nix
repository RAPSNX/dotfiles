{pkgs}: {
  gardenctl = pkgs.callPackage ./gardenctl.nix {};
  gardenlogin = pkgs.callPackage ./gardenlogin.nix {};
}
