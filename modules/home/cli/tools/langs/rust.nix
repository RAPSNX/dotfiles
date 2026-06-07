{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (!config.roles.work) {
    home.packages = lib.attrValues {
      inherit (pkgs) clang rustup;
    };
    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}
