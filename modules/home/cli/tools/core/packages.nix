{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Core utility
    coreutils # cp, mv, etc.
    dnsutils # dig, nslookup, etc.
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
    keepassxc
    sops

    # Clipboard
    wl-clipboard
  ];
}
