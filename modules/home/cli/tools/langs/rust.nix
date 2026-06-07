{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf (!config.roles.work) {
    home.packages = builtins.attrValues {
      inherit (pkgs) clang rustup;
    };
    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}
