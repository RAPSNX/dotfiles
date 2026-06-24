{
  pkgs,
  config,
  lib,
  ...
}:
{
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

  config = lib.mkIf (!config.roles.work) {
    home.packages = builtins.attrValues {
      inherit (pkgs) clang rustup;
    };
    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}
