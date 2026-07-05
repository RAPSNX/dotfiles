{ inputs, pkgs, ... }: {
  programs.tflow = {
    enable = true;
    package = inputs.tflow.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
