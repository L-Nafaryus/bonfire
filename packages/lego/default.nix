{
  bonLib,
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  version ? "bfe36067932e4594d3baf01cb6545c43b8e1f79c",
  hash ? "sha256-ye5O1HYjzpuF4k2G5KUKHNyi33fJV8K0uxyeIXieX9Q=",
  vendorHash ? "sha256-aW5Olj9t19R6J9NvuXhSXvfxdpC1yDk5/cHxZMRVJpY=",
  ...
}:
buildGoModule rec {
  pname = "lego";
  inherit version;

  src = fetchFromGitHub {
    owner = "go-acme";
    repo = "lego";
    rev = version;
    hash = hash;
  };

  inherit vendorHash;

  doCheck = false;

  subPackages = ["cmd/lego"];

  ldflags = [
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Let's Encrypt client and ACME library written in Go";
    license = licenses.mit;
    homepage = "https://go-acme.github.io/lego/";
    maintainers = with bonLib.maintainers; [L-Nafaryus];
    mainProgram = "lego";
  };

  passthru.tests.lego = nixosTests.acme;
}
