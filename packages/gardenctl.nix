{
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "gardenctl";
  version = "2.12.0-dev";

  src = fetchFromGitHub {
    # owner = "gardener";
    owner = "dergeberl";
    repo = "gardenctl-v2";
    # rev = "v${version}";
    rev = "adoptStackitProvider";
    hash = "sha256-7sZwtAtn0Tw18k7CdGEpvIWSZtM3fD9aMRzkOQ/3h6M=";
  };

  vendorHash = "sha256-uPWU5Wp1hoTZpDvZ3BuzhNtR4V2XAfKj+6ftZa5OO70=";

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
