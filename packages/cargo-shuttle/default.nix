{
  bonLib,
  craneLib,
  lib,
  pkgs,
  version ? "v0.47.0",
  hash ? "sha256-AJ+7IUxi5SRRWw0EHh9JmQHkdQU3Mhd1Nmo1peEG2zg=",
  ...
}: let
  pkg = {
    pname = "cargo-shuttle";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "shuttle-hq";
      repo = "shuttle";
      rev = version;
      hash = hash;
    };

    strictDeps = true;
    doCheck = false;

    nativeBuildInputs = with pkgs; [
      pkg-config
    ];

    buildInputs = with pkgs; [
      openssl
      zlib
    ];

    passthru = {
      update = pkgs.writeShellScriptBin "update-spoofdpi" ''
        set -euo pipefail

        latest="$(${pkgs.curl}/bin/curl -s "https://api.github.com/repos/shuttle-hq/shuttle/tags?per_page=1" | ${pkgs.jq}/bin/jq -r ".[0].name" | ${pkgs.gnused}/bin/sed 's/^v//')"

        drift rewrite --auto-hash --new-version "$latest"
      '';
    };

    meta = with lib; {
      description = "A cargo command for the shuttle platform";
      license = licenses.asl20;
      homepage = "https://shuttle.rs/";
      maintainers = with bonLib.maintainers; [L-Nafaryus];
      platforms = platforms.x86_64;
    };
  };
in let
  cargoArtifacts = craneLib.buildDepsOnly pkg;
in
  craneLib.buildPackage (
    pkg // {inherit cargoArtifacts;}
  )
