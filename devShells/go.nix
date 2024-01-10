{ pkgs, ... }:
pkgs.mkShell {
    buildInputs = with pkgs; [ go gopls gotools go-tools golangci-lint gnumake ];
}
