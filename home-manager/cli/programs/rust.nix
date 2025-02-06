{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf (!config.roles.work) {
    home.packages = with pkgs; [
      rustup
      clang
    ];
  };
}
