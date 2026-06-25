{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
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

      # AI shit
      codex

      # SSH / Security
      openssh
      libfido2
      keepassxc
      sops

      # Clipboard
      wl-clipboard

      # Monitor / I2C com
      ddcutil

      # Compiler
      gcc
      ;
  };
}
