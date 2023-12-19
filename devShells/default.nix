# self.devShells.${system}
#
{ self, nixpkgs, ... }:
let 
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

in forAllSystems(system: let 
        pkgs = nixpkgsFor.${system};
        bpkgs = self.packages.${system};
        blib = self.lib;
    in {
    
    netgen = import ./netgen.nix { inherit pkgs bpkgs; };

    openfoam = import ./openfoam.nix { inherit pkgs bpkgs; };
})
