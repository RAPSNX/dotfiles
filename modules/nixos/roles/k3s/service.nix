{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hostConfiguration.roles.k3s;
in {
  config = mkIf cfg {
    services.k3s = {
      enable = true;
      role = "server";
      package = pkgs.k3s_1_31;

      # Configuration
      configPath = builtins.toFile "config.yaml" ''
        node-label:
          - "node.rapsn.me/os=nixos"
        tls-san:
          - api.k3s.rapsn.me
        etcd-expose-metrics: true
        kube-controller-manager-arg:
          - "bind-address=0.0.0.0"
        kube-scheduler-arg:
          - "bind-address=0.0.0.0"
        kube-proxy-arg:
          - "metrics-bind-address=0.0.0.0"

        # critical config values (required on all nodes) https://docs.k3s.io/cli/server#critical-configuration-values
        cluster-cidr: 10.42.0.0/16
        service-cidr: 10.43.0.0/16
        disable-helm-controller: true
        disable:
          - servicelb
          - traefik
          - local-storage
      '';
    };
  };
}
