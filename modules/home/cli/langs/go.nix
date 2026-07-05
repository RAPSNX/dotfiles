{
  pkgs,
  config,
  ...
}:
{
  programs.go = {
    enable = true;
    package = pkgs.go;
    env = {
      GOPATH = "${config.home.homeDirectory}/go";
      CGO_ENABLED = "0";
      GOPRIVATE = [
        "github.com/stackitcloud"
        "dev.azure.com/*"
      ];
    };
  };
}
