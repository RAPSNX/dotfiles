{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Host specific configuration
  hostConfig = {
    boot = {
      enable = true;
      armSupport = true;
      supportedFilesystems = [ "ntfs" ];
    };

    user = {
      name = "rap";
      extraGroups = [
        "networkmanager"
        "wireshark"
        "i2c"
      ];
      extraOptions = {
        initialHashedPassword = "$y$j9T$DZQaaK3xGqarN8KE8qnw..$dvgiS7dso5LboGRRf0dcyct/LQUFp4J0LUo2ZRRdTr8";
      };
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
      gaming.enable = true;
    };
  };

  # TODO: Why is this in the zion host file?
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  # TODO: Why is this in the zion host file?
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      keyboard = {
        layout = "eu,de,de";
        variant = ",neo_qwertz,";
      };
      idle.timeout = 300;
    };
  };

  # TODO: Why is this in the zion host file?
  services.greetd.settings.default_session = {
    command = lib.mkForce "${config.programs.noctalia-greeter.package}/bin/noctalia-greeter-session --";
    user = "greeter";
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
    systemPackages = [
      pkgs.qt6.qtwayland
    ];

    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };
  };

  hardware.i2c.enable = true;

  services.udev = {
    packages = [
      pkgs.qmk-udev-rules
    ];
  };
}
