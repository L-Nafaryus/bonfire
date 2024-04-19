{ pkgs, ... }:
pkgs.mkShellNoCC {
    packages = with pkgs; [ 
        go 
        gopls 
        gotools 
        go-tools 
        golangci-lint 
        gnumake 
    ];
}
