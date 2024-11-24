{
  bonLib,
  lib,
  pkgs,
  version ? "v0.10.0",
  hash ? "sha256-e6TPklWp5rvNypnI0VHqOjzZhkYsZcp+jkXUlYxMBlU=",
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

  vendorHash = "sha256-kmp+8MMV1AHaSvLnvYL17USuv7xa3NnsCyCbqq9TvYE=";

  doCheck = false;

  ldflags = ["-s" "-w" "-X main.version=${version}" "-X main.builtBy=nixpkgs"];

  passthru.update = pkgs.writeShellScriptBin "update-spoofdpi" ''
    set -euo pipefail

    latest="$(${pkgs.curl}/bin/curl -s "https://api.github.com/repos/xvzc/SpoofDPI/releases?per_page=1" | ${pkgs.jq}/bin/jq -r ".[0].tag_name" | ${pkgs.gnused}/bin/sed 's/^v//')"

    drift rewrite --auto-hash --new-version "$latest"
  '';

  meta = with lib; {
    homepage = "https://github.com/xvzc/SpoofDPI";
    description = "A simple and fast anti-censorship tool written in Go";
    license = licenses.asl20;
    maintainers = with bonLib.maintainers; [L-Nafaryus];
    broken = false;
    mainProgram = "spoof-dpi";
  };
}
