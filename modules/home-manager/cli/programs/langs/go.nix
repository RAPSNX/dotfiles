{pkgs, ...}: {
  programs.go = {
    enable = true;
    package = pkgs.go;
    goPath = "go";
    goBin = "go/bin";
    goPrivate = [
      "github.com/stackitcloud"
      "dev.azure.com/*"
    ];
  };
}
