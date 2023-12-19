{
    description = "Example with hello nix.";
    nixConfig.bash-prompt = "\[nix-develop\]$ ";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, ... }:
    let
        systems = [ "x86_64-linux" ];
        forAllSystems = nixpkgs.lib.genAttrs systems;
        nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {
        packages = forAllSystems (system: {
            example = let
                pkgs = nixpkgsFor.${system};
                pname = "example";
                version = "1.0";

            in pkgs.stdenv.mkDerivation {
                inherit pname version;

                # local source
                src = ./.;

                nativeBuildInputs = with pkgs; [ cmake ninja ];

                meta = with pkgs.lib; {
                    homepage = "https://www.example.org/";
                    description = "Example with hello nix.";
                    license = licenses.cc0;
                    platforms = platforms.linux;
                    maintainers = [];
                    broken = false;
                };
            };

            default = self.packages.${system}.example;
        });

        devShells = forAllSystems (system: {
            example = let
                pkgs = nixpkgsFor.${system};
                example = self.packages.${system}.example;

            in pkgs.mkShellNoCC {
                packages = [
                    example
                ];
            };

            default = self.devShells.${system}.example;
        });

        apps = forAllSystems (system: {
            example = let
                pkgs = nixpkgsFor.${system};
                example = self.packages.${system}.example;

            in {
                type = "app";
                program = "${example}/bin/hello-nix";
            };

            default = self.apps.${system}.example;
        });

    };
}
