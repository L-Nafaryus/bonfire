{ self, nixpkgs, ... }:
let 
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

in forAllSystems(system: let 
        pkgs = nixpkgsFor.${system};
        bpkgs = self.packages.${system};
        blib = self.lib;
    in {
    
    example = blib.mkApp { drv = bpkgs.example; name = "hello-nix"; };
   
    netgen = blib.mkApp { drv = bpkgs.netgen; };

    spoof-dpi = blib.mkApp { drv = bpkgs.spoof-dpi; };
})
