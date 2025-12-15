{pkgs, ...}: {
  home.packages = with pkgs; [
    # Audio
    pavucontrol
    spek
    vlc

    # Screenshot / Recording
    grimblast
    wf-recorder

    # Tools
    nwg-displays
    nwg-look
    gparted
    gnome-disk-utility

    # Explorer
    xfce.thunar
  ];
}
