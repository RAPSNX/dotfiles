{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.roles.cli.core.graphicalTools = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install graphical utilities from the core CLI module.";
  };

  config.home.packages =
    (builtins.attrValues {
      # Core utility
      inherit (pkgs)
        coreutils
        dnsutils
        gnumake
        gnutar
        gzip
        unzip
        gnused
        gnugrep
        killall
        pciutils
        parallel

        # Inspection
        htop

        # Network tools
        gost
        inetutils
        curl
        wget

        # Network inspection
        termshark
        nmap
        netcat
        tcpdump
        iproute2

        # Text processing
        jq
        yq-go
        gawk

        # Find utils
        fd
        ripgrep

        # Copy tools
        rclone

        # SSH / Security
        openssh
        libfido2

        # AI Shit
        codex
        claude-code
        nodejs
        ;
    })
    ++ lib.optionals config.roles.cli.core.graphicalTools [
      pkgs.keepassxc
      pkgs.wl-clipboard
      pkgs.ddcutil
    ];

  config.programs = {
    bat.enable = true;
    fzf = {
      enable = true;
      historyWidget.command = "";
    };
    btop.enable = true;
    zoxide.enable = true;
    neonix.enable = true;
    eza.enable = true;
  };
}
