{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkIf (!config.roles.workdevice) {
    home.packages = with pkgs; [
      rustup
      clang
    ];
    home.sessionPath = ["$HOME/.cargo/bin"];
  };
}
