{
  pkgs,
  drift,
  ...
}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    sops
    mkpasswd
    jq
    cachix
    drift
  ];
}
