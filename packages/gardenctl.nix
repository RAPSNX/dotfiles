{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "gardenctl";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "gardener";
    repo = "gardenctl-v2";
    rev = "v${version}";
    hash = "sha256-OgaTmqtygssPAEiWC0Ug+8+TwPeHx+ax74+clNGDNcU=";
  };

  vendorHash = "sha256-CfQNJerLcHlfC9zKNfHeWoMCba9WwLQ6FC2MOuoBvmc=";

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
