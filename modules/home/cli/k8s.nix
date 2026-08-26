{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    # OCI tooling
    inherit (pkgs)
      podman-tui
      docker-compose
      dive
      crane

      # Kubernetes tooling
      kubectl
      kubernetes-helm
      fluxcd
      ;
  };
}
