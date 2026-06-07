{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "gardenlogin";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "gardener";
    repo = "gardenlogin";
    rev = "v${version}";
    hash = "sha256-Qb++u6Mug1NPGxp2iAtAy34m7eukE0vVPRc6h7OXeQ0=";
  };
  vendorHash = "sha256-/0oZkLhKyHmHf+nfIU6fp0Cf24vxLYXmeWc+q8rz3s0=";

  env.CGO_ENABLED = 0;

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X k8s.io/component-base/version.gitVersion=v${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    ln -s $out/bin/${pname} $out/bin/kubectl-${pname}
  '';
}
