{ pkgs, lib, ... }:
{
  environment.systemPackages = lib.attrValues {
    # General
    inherit (pkgs) util-linux coreutils-full dmidecode;

    inherit (pkgs) gnome-system-monitor;

    # Disks
    inherit (pkgs) nwipe gparted smartmontools gsmartcontrol iotop nvme-cli fio gnome-disk-utility;

    # Networking
    inherit (pkgs) wireshark iputils tshark iperf3 netcat-gnu nmap tcpdump ethtool;

    # Memory
    inherit (pkgs) memtester memtest86plus;

    # CPU
    inherit (pkgs) sysbench stress cpuid;

    # Copy
    inherit (pkgs) rclone rsync;

    # Hardware
    inherit (pkgs) usbutils pciutils hardinfo2;
  };
}
