{pkgs, ...}: {
  imports = [
    ./k9s.nix
    ./krewfile.nix
    ./podman.nix
    ./kubecolor.nix
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
