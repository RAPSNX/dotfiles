{pkgs}: [
  # Programs
  "systemd-run --user --unit browser firefox-devedition"
  "uwsm app -- ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
]
