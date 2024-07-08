{
  bonfire,
  lib,
  pkgs,
  version ? "0.8",
  hash ? "sha256-kPCdOZl4m7KBb970TjJokXorKfnCvuV5Uq7lFQIh1z8=",
  vendorHash ? "sha256-ib9xRklkLfrDCuLf7zDkJE8lJiNiUMPZ01MDxvqho6o=",
  ...
}:
pkgs.buildGoModule {
  pname = "spoofdpi";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "xvzc";
    repo = "SpoofDPI";
    rev = version;
    hash = hash;
  };

  inherit vendorHash;

  doCheck = false;

  ldflags = ["-s" "-w" "-X main.version=${version}" "-X main.builtBy=nixpkgs"];

  meta = with lib; {
    homepage = "https://github.com/xvzc/SpoofDPI";
    description = "A simple and fast anti-censorship tool written in Go";
    license = licenses.asl20;
    maintainers = with bonfire.lib.maintainers; [L-Nafaryus];
    broken = false;
    mainProgram = "spoof-dpi";
  };
}
