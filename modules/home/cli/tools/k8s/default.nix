{ pkgs, lib, ... }:
{
  imports = [
    ./k9s.nix
    ./krewfile.nix
    ./kubecolor.nix
  ];

  home.packages = lib.attrValues {
    # OCI tooling
    inherit (pkgs) podman-tui docker-compose dive crane;

    # Kubernetes tooling
    inherit (pkgs) kubectl kubernetes-helm fluxcd;
  };
}
