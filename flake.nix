{
  description = "Derivation lit";

  nixConfig = {
    extra-substituters = [
      "https://cache.elnafo.ru"
      "https://bonfire.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.elnafo.ru:j3VD+Hn+is2Qk3lPXDSdPwHJQSatizk7V82iJ2RP1yo="
      "bonfire.cachix.org-1:mzAGBy/Crdf8NhKail5ciK7ZrGRbPJJobW6TwFb7WYM="
    ];
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
      inputs.bonfire.follows = "";
    };
    obs-image-reaction = {
      url = "github:L-Nafaryus/obs-image-reaction";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";

        devshell.follows = "";
        flake-compat.follows = "";
        git-hooks.follows = "";
        home-manager.follows = "";
        nix-darwin.follows = "";
        treefmt-nix.follows = "";
      };
    };
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    elnafo-radio = {
      url = "git+https://vcs.elnafo.ru/L-Nafaryus/elnafo-radio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-std.url = "github:chessai/nix-std";
  };

  outputs = {self, ...} @ inputs: let
    lib = inputs.nixpkgs.lib;

    bonLib = import ./lib {inherit lib inputs;};
    bonModules = self.nixosModules;
    # no bonPkgs, it must be defined by appropriate system + skip a possible infinite recursion
  in {
    lib = bonLib;

    packages = import ./packages {inherit lib bonLib self inputs;};

    nixosModules = import ./nixosModules {
      inherit lib bonLib self;
      check = false;
    };

    nixosConfigurations = import ./nixosConfigurations {inherit lib inputs bonModules bonLib self;};

    hydraJobs = {
      # filter broken packages ?
      packages = lib.filterAttrsRecursive (name: value: !bonLib.isBroken value) self.packages;
    };

    templates = {
      rust = {
        path = ./templates/rust;
        description = "Basic Rust template";
      };
    };

    apps = import ./apps {
      inherit self;
      inherit (inputs) nixpkgs;
    };

    devShells = import ./devShells {
      inherit self;
      inherit (inputs) nixpkgs;
    };
  };
}
