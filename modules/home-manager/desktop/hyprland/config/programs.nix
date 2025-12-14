{
  bind = [
    "SUPER,RETURN, exec, uwsm app -- alacritty"
    "SUPER,E, exec, uwsm app -- fuzzel"
    "SUPER,P, exec, wlogout"
    "SUPER,Q, killactive"

    # Mumble
    "SUPER,Z, exec, mumble rpc togglemute"
    "SUPER+SHIFT,Z, exec, mumble rpc toggledeaf"

    # Notification center
    "SUPER,N, exec, swaync-client -t"
  ];
}
