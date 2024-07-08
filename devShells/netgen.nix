{
  pkgs,
  bonfire-pkgs,
  ...
}:
pkgs.mkShellNoCC {
  packages = [
    bonfire-pkgs.netgen
    pkgs.python3
  ];

  shellHook = bonfire-pkgs.netgen.passthru.shellHook;
}
