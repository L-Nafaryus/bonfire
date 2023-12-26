{ lib, pkgs, cranelib, ... }:
cranelib.buildPackage {
    src = cranelib.cleanCargoSource (cranelib.path ./.);
    strictDeps = true;

    buildInputs = [];
}
