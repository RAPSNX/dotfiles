{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.roles.k3s;
  poolName = "kubex-main";
in
{
  config = lib.mkIf cfg {
    systemd.services.wait-for-zfs-pool = {
      description = "Wait for unlocked ZFS pool ${poolName}";

      before = [ "k3s.service" ];

      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "infinity";
      };

      script = ''
        set -euo pipefail

        pool="${poolName}"

        # Wait until pool can be imported.
        until ${pkgs.zfs}/bin/zpool list -H "$pool" >/dev/null 2>&1; do
          echo "Importing ZFS pool $pool"
          if ! ${pkgs.zfs}/bin/zpool import -N "$pool"; then
            echo "Import failed, retrying in 5s"
          fi
          sleep 5
        done

        # Wait for an operator to unlock the pool.
        while [ "$(${pkgs.zfs}/bin/zfs get -H -o value keystatus "$pool")" != "available" ]; do
          echo "Waiting for ZFS pool $pool to be unlocked with: zfs load-key $pool"
          sleep 5
        done

        # Final readiness check.
        test "$(${pkgs.zfs}/bin/zfs get -H -o value keystatus "$pool")" = "available"
        echo "ZFS pool $pool imported and unlocked"
      '';
    };

    systemd.services.k3s = {
      requires = [ "wait-for-zfs-pool.service" ];
      after = [ "wait-for-zfs-pool.service" ];
    };
  };
}
