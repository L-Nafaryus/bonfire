{ crane-lib, pkgs, ... }:
crane-lib.devShell {
    packages = with pkgs; [
        sops
        mkpasswd
        nil
        jq
        cachix
        nodejs
        python3
        marksman
    ];
}
