{
    description = "Derivation lit";

    nixConfig = {
        extra-substituters = ["https://bonfire.cachix.org"];
        extra-trusted-public-keys = ["bonfire.cachix.org-1:mzAGBy/Crdf8NhKail5ciK7ZrGRbPJJobW6TwFb7WYM="];
    };

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
        cachix = { url = "github:cachix/devenv/v0.6.3"; inputs.nixpkgs.follows = "nixpkgs"; };
        agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    };

    outputs = inputs @ { self, nixpkgs, home-manager, agenix, ... }: {

        lib = import ./lib {};
        
        nixosConfigurations = {
            astora = with nixpkgs; lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    home-manager.nixosModules.home-manager
                    agenix.nixosModules.default
                    ./nixosConfigurations/astora
                    ./nixosModules/bonfire.nix
                ];
                specialArgs = { inherit inputs; };
            };
        };

        nixosModules = {
            bonfire = import ./nixosModules/bonfire.nix;
        };

        templates = {
            rust = { path = ./templates/rust; description = "Basic Rust template"; };
        };

        packages = import ./packages { inherit self nixpkgs; };

        apps = import ./apps { inherit self nixpkgs; };

        devShells = import ./devShells { inherit self nixpkgs; };
    };
}
