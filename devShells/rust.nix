{
  pkgs,
  crane-lib,
  ...
}:
crane-lib.devShell {
  packages = [
    pkgs.cargo-watch
  ];
}
