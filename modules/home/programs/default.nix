{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    # Audio
    inherit (pkgs)
      spek
      vlc

      # Screenshot / Recording
      wf-recorder
      noisetorch
      satty
      grim
      slurp

      # Tools
      nwg-displays
      nwg-look
      gparted
      gnome-disk-utility

      # Explorer
      thunar

      # Note taking
      obsidian

      # Keyboard
      zmk-studio
      ;
  };
}
