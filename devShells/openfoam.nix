{ pkgs, bpkgs, ... }:
pkgs.mkShellNoCC {
    packages = with pkgs; [
        bpkgs.openfoam
        mpi
    ];

    shellHook = ''
        . ${bpkgs.openfoam}/OpenFOAM-${bpkgs.openfoam.major}/etc/bashrc
    '';
}
