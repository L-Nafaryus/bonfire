{
  bonLib,
  craneLib,
  lib,
  pkgs,
  version ? "v0.44.0",
  hash ? "sha256-3u2GWgDQpa4sU/66vS6S+JwCEL/fvy8MTsATRs7RGVs=",
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
