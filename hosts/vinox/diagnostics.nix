{ pkgs, ... }:
{
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      # General
      util-linux
      coreutils-full
      dmidecode

      gnome-system-monitor

      # Disks
      nwipe
      gparted
      smartmontools
      gsmartcontrol
      iotop
      nvme-cli
      fio
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
      sysbench
      stress
      cpuid

      # Copy
      rclone
      rsync

      # Hardware
      usbutils
      pciutils
      hardinfo2
      ;
  };
}
