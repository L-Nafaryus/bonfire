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
    catppuccin = {
      url = "github:catppuccin/nix";
    };
    oscuro = {
      url = "github:L-Nafaryus/oscuro";
    };
    obs-image-reaction = {
      url = "github:L-Nafaryus/obs-image-reaction";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-mailserver,
    sops-nix,
    crane,
    fenix,
    catppuccin,
    oscuro,
    ...
  } @ inputs: let
    lib = import ./lib {inherit (nixpkgs) lib;};
  in {
    inherit lib;

    nixosConfigurations = {
      astora = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./nixosConfigurations/astora
          self.nixosModules.bonfire
          self.nixosModules.spoofdpi
          (import ./nixosModules {
            lib = nixpkgs.lib;
            self = self;
          })
          .configModule
        ];
        specialArgs = {inherit self inputs;};
      };

      catarina = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-mailserver.nixosModules.mailserver
          sops-nix.nixosModules.sops
          oscuro.nixosModules.oscuro
          ./nixosConfigurations/catarina
          self.nixosModules.bonfire
          self.nixosModules.spoofdpi
          self.nixosModules.papermc
          self.nixosModules.qbittorrent-nox
          (import ./nixosModules {
            lib = nixpkgs.lib;
            self = self;
          })
          .configModule
        ];
        specialArgs = {inherit self;};
      };
    };

    nixosModules =
      lib.importNamedModules
      (import ./nixosModules {
        lib = nixpkgs.lib;
        self = self;
      })
      .modules;

    templates = {
      rust = {
        path = ./templates/rust;
        description = "Basic Rust template";
      };
    };

    packages = import ./packages {inherit self inputs;};

    apps = import ./apps {inherit self nixpkgs;};

    devShells = import ./devShells {inherit self nixpkgs;};

    configurations = import ./configurations {inherit self inputs;};

    hydraJobs = {
      inherit (self) packages;
    };
  };
}
