{
  bind = [
    "SUPER,RETURN, exec, uwsm app -- alacritty"
    "SUPER,E, exec, uwsm app -- fuzzel"
    "SUPER,P, exec, wlogout"
    "SUPER,Q, killactive"

    # Mumble
    "SUPER,Z, exec, mumble rpc togglemute"
    "SUPER+SHIFT,Z, exec, mumble rpc toggledeaf"

    # Mouseless
    "SUPER,SPACE, exec, wl-kbptr -o modes=tile,bisect,click"
  ];
}
