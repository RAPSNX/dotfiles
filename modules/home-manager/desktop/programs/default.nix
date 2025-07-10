{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    # Tools
    ./audio.nix
    # TODO: make configurable or remove
    # ./tray.nix

    # Programs
    ./spotify.nix
    # ./nextcloud.nix

    # Browsers
    ./firefox.nix
    ./chromium.nix

    # Custom shell scripts
    ./screenshot.nix
  ];

  # Default desktop programs
  home.packages = with pkgs;
    [
      xfce.thunar
      vlc
      # gparted
      # gnome-disk-utility
    ]
    ++ lib.optionals config.roles.workdevice [
      stackit-cli
      openstackclient-full
      vault-bin
    ];
}
