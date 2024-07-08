{pkgs, ...}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    sops
    mkpasswd
    jq
    cachix
  ];
}
