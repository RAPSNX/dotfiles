{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    # Tools
    ./audio.nix
    ./tray.nix

    # Programs
    ./spotify.nix
    ./nextcloud.nix

    # Browsers
    ./firefox.nix
    ./chromium.nix
  ];

  # Default desktop programs
  home.packages = with pkgs;
    [
      xfce.thunar
      vlc
      grimblast
      nwg-displays
      gparted
      gnome-disk-utility
    ]
    ++ lib.optionals config.roles.workdevice [
      stackit-cli
      openstackclient-full
      vault-bin
    ];
}
