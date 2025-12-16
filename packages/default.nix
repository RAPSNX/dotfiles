{pkgs}: {
  gardenctl = pkgs.callPackage ./gardenctl {};
  gardenlogin = pkgs.callPackage ./gardenlogin {};
}
