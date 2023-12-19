{ pkgs, bpkgs, ... }:
let 
    python = pkgs.python3.withPackages(ps: []);

in pkgs.mkShellNoCC {
    packages = with pkgs; [
        bpkgs.netgen
        python
    ];

    shellHook = ''
        export PYTHONPATH="${python}/${python.sitePackages}"
        export PYTHONPATH="$PYTHONPATH:${bpkgs.netgen}/${python.sitePackages}"
    '';
}
