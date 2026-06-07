{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.hostConfig.roles.k3s;
  getConfig = pkgs.writeShellScriptBin "getConfig" ''
    mkdir -p ~/.kube/
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown k3s:users ~/.kube/config
  '';
in
{
  imports = [
    ./service.nix
    ./network.nix
  ];

  options.hostConfig.roles.k3s = lib.mkEnableOption "Enable k3s cluster configuration.";

  config = lib.mkIf cfg {
    environment = {
      shellAliases = {
        k = "kubectl";
      };
      systemPackages = lib.attrValues {
        inherit getConfig;
        inherit (pkgs) kubectl;

        # Storage
        inherit (pkgs) zfs;
      };
    };

    # Link zfs to be in PATH for openebs-provisioner
    system.activationScripts.link-zsh = lib.stringAfter [ "var" ] ''
      ln -sf /run/current-system/sw/bin/zfs /usr/bin/zfs
    '';

    # Enable smartmon to collect disk health data
    services.smartd = {
      enable = true;
      autodetect = true;
      # SMART Automatic Offline Testing on startup, and schedules short self-tests daily, and long self-tests weekly.
      defaults.monitored = "-a -o on -s (S/../.././02|L/../../7/04)";
    };

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 8192;
    };
  };
}
