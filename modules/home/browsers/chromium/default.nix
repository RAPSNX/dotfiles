{
  pkgs,
  ...
}:
{
  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--enable-wayland-ime"
      # TODO: wait for next hl tag/release see https://github.com/hyprwm/Hyprland/discussions/11843
      "--disable-features=WaylandWpColorManagerV1"
    ];
  };

}
