{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;

    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "xterm-256color";
    mouse = true;
    keyMode = "vi";
    clock24 = true;
    historyLimit = 100000;
    escapeTime = 10;

    extraConfig = ''
      set -g focus-events on
      set -g set-clipboard on
      set -g allow-passthrough on
      set -ga terminal-features ',alacritty:RGB'
      set -ga terminal-features ',xterm-256color:RGB'
      set -ga terminal-features ',tmux-256color:RGB'

      set -g update-environment "DISPLAY WAYLAND_DISPLAY SSH_AUTH_SOCK XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME KUBECONFIG"
    '';
  };
}
