{pkgs, ...}: {
  imports = [
    ./k9s.nix
    ./krewfile.nix
    ./podman.nix
  ];

  home.packages = with pkgs; [
    # OCI tooling
    podman-tui
    docker-compose
    dive
    crane

    # Kubernetes tooling
    kubectl
    kubernetes-helm
    fluxcd
  ];
}
