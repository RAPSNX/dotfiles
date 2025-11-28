{
  pkgs,
  config,
}: {
  bind = [
    "SUPER,RETURN, exec, uwsm app -- ${(config.lib.nixGL.wrap pkgs.alacritty)}/bin/alacritty"
    "SUPER,SPACE, exec, uwsm app -- ${pkgs.fuzzel}/bin/fuzzel"
    "SUPER,P, exec, ${pkgs.wlogout}/bin/wlogout"
    "SUPER,Q, killactive"

    # Mumble
    "SUPER,Z, exec, mumble rpc togglemute"
    "SUPER+SHIFT,Z, exec, mumble rpc toggledeaf"
  ];
}
