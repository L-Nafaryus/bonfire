# self.devShells.${system}
#
{ self, nixpkgs, crane, ... }:
let 
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

in forAllSystems(system: let 
        pkgs = nixpkgsFor.${system};
        bpkgs = self.packages.${system};
        blib = self.lib;
        cranelib = crane.lib.${system};
    in {
    
    netgen = import ./netgen.nix { inherit pkgs bpkgs; };

    openfoam = import ./openfoam.nix { inherit pkgs bpkgs; };

    rust = import ./rust.nix { inherit pkgs cranelib; };

    go = import ./go.nix { inherit pkgs; };
})
