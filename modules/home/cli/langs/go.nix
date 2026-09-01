{
  pkgs,
  config,
  ...
}:
{
  home.packages = [ pkgs.ginkgo ];

  programs.go = {
    enable = true;
    package = pkgs.go;
    env = {
      GOPATH = "${config.home.homeDirectory}/go";
      GOPRIVATE = [
        "github.com/stackitcloud"
        "dev.azure.com/*"
      ];
    };
  };
}
