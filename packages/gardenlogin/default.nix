{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "gardenlogin";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "gardener";
    repo = "gardenlogin";
    rev = "v${version}";
    hash = "sha256-qvRJeOoi4/tN0Mty3xqDyTnRfkkscwenM2IRZCNB+Us=";
  };

  vendorHash = "sha256-hQKLbO6+4yDnAof81+5YWm3mIfIGWmK01rFA1+oOC4I=";

  env.CGO_ENABLED = 0;

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X k8s.io/component-base/version.gitVersion=v${version}"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    ln -s $out/bin/${pname} $out/bin/kubectl-${pname}
  '';
}
