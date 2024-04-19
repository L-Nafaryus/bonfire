# self.packages.${system}
#
{ self, nixpkgs, ... }:
let 
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

in forAllSystems(system:  
    let 
        bonfire = self;
        pkgs = nixpkgsFor.${system}; 
    in {
    
    example = pkgs.callPackage ./example { inherit bonfire; };

    netgen = pkgs.callPackage ./netgen { inherit bonfire; };
   
    dearpygui = pkgs.callPackage ./dearpygui { inherit bonfire; };

    openfoam = pkgs.callPackage ./openfoam { inherit bonfire; };

    spoofdpi = pkgs.callPackage ./spoofdpi { inherit bonfire; };

    lego = pkgs.callPackage ./lego { inherit bonfire; };

    ultimmc = pkgs.libsForQt5.callPackage ./ultimmc { inherit bonfire; };
})
