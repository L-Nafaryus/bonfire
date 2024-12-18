{
  bonLib,
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  version ? "bfe36067932e4594d3baf01cb6545c43b8e1f79c",
  hash ? "sha256-j6AlA9+whDxvpbZBCnJinKTb0+bJrSqnMgCqmWWfLig=",
  vendorHash ? "sha256-r9R+d5H5RjwzksbAlcFPyRtCGXSH1JBVfNHr5QiHA7Y=",
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
