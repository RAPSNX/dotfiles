{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # General
    util-linux
    coreutils-full
    dmidecode

    gnome-system-monitor

    # Disks
    nwipe # Disk wiper
    gparted # Partitioning
    smartmontools # Disk health
    gsmartcontrol
    iotop
    nvme-cli
    fio # I/O Benchmark
    gnome-disk-utility

    # Networking
    wireshark
    iputils
    tshark
    iperf3
    netcat-gnu
    nmap
    tcpdump
    ethtool

    # Memory
    memtester
    memtest86plus

    # CPU
    sysbench # General benchmark
    stress
    cpuid

    # Copy
    rclone
    rsync

    # Hardware
    usbutils
    pciutils
    hardinfo2
  ];
}
