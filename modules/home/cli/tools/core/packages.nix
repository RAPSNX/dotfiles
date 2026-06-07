{ pkgs, lib, ... }:
{
  home.packages = lib.attrValues {
    # Core utility
    inherit (pkgs) coreutils dnsutils gnumake gnutar gzip unzip gnused gnugrep killall pciutils parallel;

    # Inspection
    inherit (pkgs) htop;

    # Network tools
    inherit (pkgs) inetutils curl wget;

    # Network inspection
    inherit (pkgs) termshark nmap netcat tcpdump iproute2;

    # Text processing
    inherit (pkgs) jq yq-go gawk;

    # Find utils
    inherit (pkgs) fd ripgrep;

    # Copy tools
    inherit (pkgs) rclone;

    # SSH / Security
    inherit (pkgs) openssh libfido2 keepassxc sops;

    # Clipboard
    inherit (pkgs) wl-clipboard;

    # Monitor / I2C com
    inherit (pkgs) ddcutil;
  };
}
