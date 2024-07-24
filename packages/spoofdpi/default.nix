{
  bonLib,
  lib,
  pkgs,
  version ? "v0.10.0",
  hash ? "sha256-e6TPklWp5rvNypnI0VHqOjzZhkYsZcp+jkXUlYxMBlU=",
  vendorHash ? "sha256-kmp+8MMV1AHaSvLnvYL17USuv7xa3NnsCyCbqq9TvYE=",
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
    maintainers = with bonLib.maintainers; [L-Nafaryus];
    broken = false;
    mainProgram = "spoof-dpi";
  };
}
