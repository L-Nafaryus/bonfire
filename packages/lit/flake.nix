{
    description = "Basic rust template";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        crane = { url = "github:ipetkov/crane"; inputs.nixpkgs.follows = "nixpkgs"; };
    };

    outputs = inputs @ { self, nixpkgs, crane, ... }:
    let 
        forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
        nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
        packages = forAllSystems (system: {
            lit = let
                pkgs = nixpkgsFor.${system};
                cranelib = crane.lib.${system};
            in cranelib.buildPackage {
                src = cranelib.cleanCargoSource (cranelib.path ./.);
                strictDeps = true;

                buildInputs = [];
            };

            default = self.packages.${system}.lit;
        });

        checks = forAllSystems (system: { 
            inherit (self.packages.${system}.lit);

            lit-fmt = let cranelib = crane.lib.${system}; in cranelib.cargoFmt { 
                src = cranelib.cleanCargoSource (cranelib.path ./.);
            };
        });

        apps = forAllSystems (system: {
            default = {
                type = "app";
                program = "${self.packages.${system}.lit}/bin/lit"; 
            };
        });

        devShells = forAllSystems (system: {
            default = crane.lib.${system}.devShell {
                checks = self.checks.${system};

                packages = [];
            };
        });
    };

}
