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
        bonfire-lib = self.lib;
        bonfire-pkgs = self.packages.${system};

        crane = self.inputs.crane;
        crane-lib = self.inputs.crane.lib.${system};
    in {
    
    example = pkgs.callPackage ./example { inherit bonfire; };

    netgen = pkgs.callPackage ./netgen { inherit bonfire; };
   
    dearpygui = pkgs.callPackage ./dearpygui { inherit bonfire; };

    openfoam = pkgs.callPackage ./openfoam { inherit bonfire; };

    spoofdpi = pkgs.callPackage ./spoofdpi { inherit bonfire; };

    lego = pkgs.callPackage ./lego { inherit bonfire; };

    ultimmc = pkgs.libsForQt5.callPackage ./ultimmc { inherit bonfire; };

    cargo-shuttle = pkgs.callPackage ./cargo-shuttle { inherit bonfire crane-lib; };
})
