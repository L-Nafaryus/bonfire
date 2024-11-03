{pkgs, ...}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    uv
    curl
    jq
  ];
}
