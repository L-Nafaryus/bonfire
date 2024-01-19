# self.packages.${system}
#
{ self, nixpkgs, ... }:
let 
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

in forAllSystems(system: let pkgs = nixpkgsFor.${system}; in {
    
    example = pkgs.callPackage ./example {};

    netgen = pkgs.callPackage ./netgen {};
   
    dearpygui = pkgs.callPackage ./dearpygui {};

    openfoam = pkgs.callPackage ./openfoam {};

    spoofdpi = pkgs.callPackage ./spoofdpi {};

    lego = pkgs.callPackage ./lego {};

    ultimmc = pkgs.libsForQt5.callPackage ./ultimmc {};
})
