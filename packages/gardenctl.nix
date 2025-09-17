{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "gardenctl";
  version = "2.12.0-dev";

  src = fetchFromGitHub {
    owner = "gardener";
    repo = "gardenctl-v2";
    rev = "e268ad02130241b195571ebf5d1699688e0e595c";
    hash = "sha256-j6+bwhItJV7hvwmtl/tUdxwVbrGcvwfMJhOpRX4nVz0=";
  };

  vendorHash = "sha256-t0KeSM98StlqtatxLDV0tSuLw/7aej4GBr+WM++dtpU=";

  subPackages = ["/"];

  env.CGO_ENABLED = 0;

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X k8s.io/component-base/version.gitVersion=v${version}"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    mv $out/bin/{gardenctl-v2,${pname}}

    installShellCompletion --cmd ${pname} \
        --zsh  <($out/bin/${pname} completion zsh) \
        --bash <($out/bin/${pname} completion bash) \
        --fish <($out/bin/${pname} completion fish)
  '';
}
