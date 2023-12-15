{
    description = "Derivation lit";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
        cachix = { url = "github:cachix/devenv/v0.6.3"; inputs.nixpkgs.follows = "nixpkgs"; };
    };

    outputs = inputs @ { self, nixpkgs, home-manager, ... }: {
        nixosConfigurations = {
            astora = with nixpkgs; lib.nixosSystem {
                system = "x86_64-linux";
                modules = [ home-manager.nixosModules.home-manager ./nixosConfigurations/astora ./nixosModules/bonfire.nix ];
            };
        };

        nixosModules = {
            bonfire = import ./nixosModules/bonfire.nix;
        };
    };
}
