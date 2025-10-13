{
  pkgs,
  config,
  ...
}: let
  inherit (config.roles) useNixGL;
in {
  programs.chromium = {
    enable = true;
    package =
      if useNixGL
      then config.lib.nixGL.wrap pkgs.chromium
      else pkgs.chromium;
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--enable-wayland-ime"
      # TODO: wait for next hl tag/release see https://github.com/hyprwm/Hyprland/discussions/11843
      "--disable-features=WaylandWpColorManagerV1"
    ];
  };
}
