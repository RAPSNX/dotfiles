{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # Host specific configuration
  hostConfiguration = {
    boot = {
      enable = true;
      armSupport = true;
      supportedFilesystems = ["ntfs"];
    };

    user = {
      name = "rap";
      extraGroups = [
        "networkmanager"
        "wireshark"
      ];
      extraOptions = {
        initialHashedPassword = "$y$j9T$DZQaaK3xGqarN8KE8qnw..$dvgiS7dso5LboGRRf0dcyct/LQUFp4J0LUo2ZRRdTr8";
      };
      keys = [];
    };

    services = {
      printing = true;
      sound = true;
      bluetooth = true;
      opengl = true;
      podman = true;
      tailscale = true;
    };

    roles = {
      desktop = true;
    };
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true; # realtime-kit
    sudo.wheelNeedsPassword = false;
  };

  networking = {
    hostName = "zion";
    networkmanager.enable = true;
    interfaces.enp16s0 = {
      wakeOnLan.enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [qt6.qtwayland];

    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
  };

  services.udev.packages = with pkgs; [
    qmk-udev-rules
  ];
}
