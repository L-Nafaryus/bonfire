{
  pkgs,
  bonfire-pkgs,
  ...
}:
pkgs.mkShellNoCC {
  packages = [
    bonfire-pkgs.openfoam
    pkgs.mpi
  ];

  shellHook = bonfire-pkgs.openfoam.passthru.shellHook;
}
