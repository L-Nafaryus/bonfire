{
    description = "Derivation lit";

    nixConfig = {
        extra-substituters = ["https://bonfire.cachix.org"];
        extra-trusted-public-keys = ["bonfire.cachix.org-1:mzAGBy/Crdf8NhKail5ciK7ZrGRbPJJobW6TwFb7WYM="];
    };

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = { 
            url = "github:nix-community/home-manager"; 
            inputs.nixpkgs.follows = "nixpkgs"; 
        };
        devenv = { 
            url = "github:cachix/devenv"; 
            inputs.nixpkgs.follows = "nixpkgs"; 
        };
        nixgl = { 
            url = "github:guibou/nixGL"; 
            inputs.nixpkgs.follows = "nixpkgs"; 
        };
        nixos-mailserver = { 
            url = "gitlab:simple-nixos-mailserver/nixos-mailserver"; 
            inputs.nixpkgs.follows = "nixpkgs"; 
        };
        sops-nix = { 
            url = "github:Mic92/sops-nix"; 
            inputs.nixpkgs.follows = "nixpkgs"; 
        };
        crane = { 
            url = "github:ipetkov/crane"; 
            inputs.nixpkgs.follows = "nixpkgs"; 
        };
        fenix = { 
            url = "github:nix-community/fenix"; 
            inputs.nixpkgs.follows = "nixpkgs"; 
            inputs.rust-analyzer-src.follows = ""; 
        };
    };

    outputs = inputs @ { self, nixpkgs, home-manager, devenv, nixgl, nixos-mailserver, sops-nix, crane, fenix, ... }: {

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
                    nixos-mailserver.nixosModules.mailserver
                    sops-nix.nixosModules.sops
                    ./nixosConfigurations/catarina
                    ./nixosModules/bonfire.nix
                    self.nixosModules.spoofdpi
                    self.nixosModules.papermc
                    self.nixosModules.qbittorrent-nox
                ];
                specialArgs = { inherit inputs self; };
            };
        };

        nixosModules = {
            bonfire = import ./nixosModules/bonfire.nix;

            spoofdpi = import ./nixosModules/spoofdpi { inherit self; };

            papermc = import ./nixosModules/papermc { inherit self; };

            qbittorrent-nox = import ./nixosModules/qbittorrent-nox { inherit self; };
        };

        templates = {
            rust = { 
                path = ./templates/rust; 
                description = "Basic Rust template"; 
            };
        };

        packages = import ./packages { inherit self nixpkgs; };

        apps = import ./apps { inherit self nixpkgs; };

        devShells = import ./devShells { inherit self nixpkgs; };
    };
}
