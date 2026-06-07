{ pkgs, lib, ... }:
{
  home.packages = lib.attrValues {
    # Audio
    inherit (pkgs) pavucontrol spek vlc;

    # Screenshot / Recording
    inherit (pkgs) grimblast wf-recorder;

    # Tools
    inherit (pkgs) nwg-displays nwg-look gparted gnome-disk-utility;

    # Explorer
    inherit (pkgs) thunar;

    # Note taking
    inherit (pkgs) obsidian;
  };
}
