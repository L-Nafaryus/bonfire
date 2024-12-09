{
  bonLib,
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  version ? "0bbf5ab59cda8beaedf5b1ce21a3d1bf0eb48fc5",
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
  };

  passthru.tests.lego = nixosTests.acme;
}
