{
  bonLib,
  craneLib,
  lib,
  pkgs,
  dreamBuildPackage,
  dreamModules,
  version ? "v1.7.0",
  # TODO: assign hash
  hash ? "",
  ...
}: let
  src = pkgs.fetchFromGitHub {
    owner = "Marekkon5";
    repo = "onetagger";
    rev = version;
    hash = hash;
  };

  client = dreamBuildPackage {
    extraModules = [
      {
        # TODO: locate root
        paths.projectRoot = ./client;
        paths.projectRootFile = "flake.nix";
        paths.package = ./client;
      }
    ];
    module = {
      lib,
      config,
      dream2nix,
      ...
    }: {
      name = "client";
      version = "0.0.0";

      imports = [
        dreamModules.WIP-nodejs-builder-v3
      ];

      mkDerivation = {
        # TODO: add source path
        src = src;
      };

      deps = {nixpkgs, ...}: {
        inherit
          (nixpkgs)
          fetchFromGitHub
          stdenv
          ;
      };

      WIP-nodejs-builder-v3 = {
        # TODO: generate lock and pass here
        packageLockFile = "${config.mkDerivation.src}/package-lock.json";
      };
    };
  };

  common = rec {
    pname = "onetagger";
    inherit version;

    src = pkgs.lib.cleanSourceWith {
      src = src;
      filter = path: type: (craneLib.filterCargoSources path type);
    };

    # TODO: understand broken git+ dependency
    songrec = craneLib.downloadCargoPackageFromGit {
      git = "https://github.com/Marekkon5/SongRec.git";
      rev = "d52238b3aa3b092ffcf9766794583d84c60473bb";
    };

    cargoVendorDir = craneLib.vendorCargoDeps {
      src = src;
    };

    strictDeps = false;

    nativeBuildInputs = with pkgs; [pkg-config];

    buildInputs = with pkgs; [alsa-lib cairo pango webkitgtk_4_1];

    configurePhase = ''
      cp -rv ${client}/dist ./client/
    '';
  };

  cargoArtifacts = craneLib.buildDepsOnly common;
in
  craneLib.buildPackage (common // {inherit cargoArtifacts;})
