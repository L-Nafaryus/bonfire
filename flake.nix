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
        crane = { url = "github:ipetkov/crane"; inputs.nixpkgs.follows = "nixpkgs"; };
        nixgl = { url = "github:guibou/nixGL"; inputs.nixpkgs.follows = "nixpkgs"; };
        simple-nixos-mailserver = { url = "gitlab:simple-nixos-mailserver/nixos-mailserver"; inputs.nixpkgs.follows = "nixpkgs"; };
        sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    };

    outputs = inputs @ { self, nixpkgs, home-manager, crane, nixgl, simple-nixos-mailserver, sops-nix, ... }: {


        lib = import ./lib {};
        
        nixosConfigurations = {
            astora = with nixpkgs; lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    home-manager.nixosModules.home-manager
                    ./nixosConfigurations/astora
                    ./nixosModules/bonfire.nix
                    self.nixosModules.spoofdpi
                ];
                specialArgs = { inherit inputs self; };
            };

            catarina = with nixpkgs; lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./nixosConfigurations/catarina
                    ./nixosModules/bonfire.nix
                    self.nixosModules.spoofdpi
                    simple-nixos-mailserver.nixosModules.mailserver
                    sops-nix.nixosModules.sops
                ];
                specialArgs = { inherit inputs self; };
            };
        };

        nixosModules = {
            bonfire = import ./nixosModules/bonfire.nix;

            spoofdpi = import ./nixosModules/spoofdpi { inherit self; };
        };

        templates = {
            rust = { path = ./templates/rust; description = "Basic Rust template"; };
        };

        packages = import ./packages { inherit self nixpkgs; };

        apps = import ./apps { inherit self nixpkgs; };

        devShells = import ./devShells { inherit self nixpkgs crane; };
    };
}
