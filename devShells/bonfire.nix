{ crane-lib, pkgs, ... }:
crane-lib.devShell {
    packages = with pkgs; [
        # nil
        jq
        cachix
    ];
}
