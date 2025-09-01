{pkgs, ...}: {
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "${pkgs.systemd}/bin/systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = "loginctl terminate-user $USER";
        text = "Logout";
        keybind = "L";
      }
      {
        label = "shutdown";
        action = "${pkgs.systemd}/bin/systemctl poweroff";
        text = "Shutdown";
        keybind = "S";
      }
      {
        label = "suspend";
        action = "${pkgs.systemd}/bin/systemctl suspend";
        text = "Suspend";
        keybind = "s";
      }
      {
        label = "reboot";
        action = "${pkgs.systemd}/bin/systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];
    style = builtins.readFile ./style.css;
  };

  xdg.configFile."wlogout/icons" = {
    recursive = true;
    source = ./icons;
  };
}
