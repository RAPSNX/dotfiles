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
      description = "Prepare ZFS pool ${poolName} for k3s";
      before = [ "k3s.service" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "infinity";
      };
      script = ''
        set -euo pipefail

        pool="${poolName}"
        key_source="rap@nixberry"

        echo "Ensuring ZFS pool $pool is imported"
        if ! ${pkgs.zfs}/bin/zpool list -H "$pool" >/dev/null 2>&1; then
          ${pkgs.zfs}/bin/zpool import -aN
        fi

        until ${pkgs.zfs}/bin/zpool list -H "$pool" >/dev/null 2>&1; do
          echo "Waiting for ZFS pool $pool to appear"
          sleep 2
        done

        echo "Loading encryption key for $pool from $key_source"
        # Refuse an unverified nixberry host key; accepting a new key here
        # would allow a network attacker to impersonate the key server.
        while true; do
          if key="$(${pkgs.util-linux}/bin/runuser -u ${config.hostConfig.user.name} -- ${pkgs.openssh}/bin/ssh \
            -o BatchMode=yes \
            -o ConnectTimeout=10 \
            -o StrictHostKeyChecking=yes \
            "$key_source" ulock-agent get)"; then
            break
          fi

          echo "Waiting for SSH access to $key_source"
          sleep 5
        done

        printf '%s\n' "$key" | ${pkgs.zfs}/bin/zfs load-key "$pool"
      '';
    };

    systemd.services.k3s = {
      requires = [ "wait-for-zfs-pool.service" ];
      after = [ "wait-for-zfs-pool.service" ];
    };
  };
}
