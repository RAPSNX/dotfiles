{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "gardenctl";
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "gardener";
    repo = "gardenctl-v2";
    rev = "v${version}";
    hash = "sha256-hdXOgzRO3Nq81n8YH/RFWHTTR7TNXAw2RnDWOxNHySU=";
  };

  vendorHash = "sha256-xscuOXZcOPOeWROFnSCYUO8AZ6GfQAwjzRVAtbSrsR4=";

  subPackages = [ "/" ];

  env.CGO_ENABLED = 0;

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X k8s.io/component-base/version.gitVersion=v${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    mv $out/bin/{gardenctl-v2,${pname}}

    installShellCompletion --cmd ${pname} \
        --zsh  <($out/bin/${pname} completion zsh) \
        --bash <($out/bin/${pname} completion bash) \
        --fish <($out/bin/${pname} completion fish)
  '';
}
