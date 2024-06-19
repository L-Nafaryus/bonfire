# self.packages.${system}
#
{ self, nixpkgs, ... }:
let 
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

in forAllSystems(system:  
    let 
        pkgs = nixpkgsFor.${system}; 

        bonfire = self;
        bonlib = self.lib;
        bonpkgs = self.packages.${system};

        crane = self.inputs.crane;
        crane-lib = self.inputs.crane.mkLib pkgs;

        fenix = self.inputs.fenix;
    in {
    
    bonfire-docs = pkgs.callPackage ./bonfire-docs { inherit bonfire; };

    netgen = pkgs.callPackage ./netgen { inherit bonfire; };
   
    dearpygui = pkgs.callPackage ./dearpygui { inherit bonfire; };

    openfoam = pkgs.callPackage ./openfoam { inherit bonfire; };

    spoofdpi = pkgs.callPackage ./spoofdpi { inherit bonfire; };

    lego = pkgs.callPackage ./lego { inherit bonfire; };

    ultimmc = pkgs.libsForQt5.callPackage ./ultimmc { inherit bonfire; };

    cargo-shuttle = pkgs.callPackage ./cargo-shuttle { inherit bonfire crane-lib; };

    nix-minimal = pkgs.callPackage ./nix-minimal { inherit bonpkgs bonlib; };

    nix-runner = pkgs.callPackage ./nix-runner { inherit bonpkgs bonlib; };
})
# map (ps: (map (p: { name = p; systems = [ ps.${p}.system ]; type = if ps.${p}?imageTag then "image" else "package"; }) (builtins.attrNames ps))) (map (s: bf.packages.${s}) (builtins.attrNames bf.packages))
