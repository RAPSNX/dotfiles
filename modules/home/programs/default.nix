{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    # Audio
    inherit (pkgs)
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
      thunar

      # Note taking
      obsidian
      ;
  };
}
