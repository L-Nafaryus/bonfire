{
    description = "Who said nix-nix? It's a dotfiles!";

    inputs = {
        # Core dependencies.
        nixpkgs.url = "nixpkgs/nixos-unstable";
        nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
        home-manager = {
            url = "github:rycee/home-manager/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nur = {
            url = "github:nix-community/NUR";
        };

        # Extras
        emacs-overlay.url  = "github:nix-community/emacs-overlay";
        nixos-hardware.url = "github:nixos/nixos-hardware";
        devenv.url = "github:cachix/devenv/v0.6.2";
    };

    outputs = inputs @ {
        self, nixpkgs, nixpkgs-unstable, nur,
        emacs-overlay, nixos-hardware, devenv,
        ...
    }:
    let
        inherit (builtins) baseNameOf;
        inherit (lib) nixosSystem mkIf removeSuffix attrNames attrValues;
        inherit (lib.custom) mapModules mapModulesRec mapHosts;

        system = "x86_64-linux";

        lib = nixpkgs.lib.extend (self: super: {
            custom = import ./lib {
                inherit pkgs inputs; lib = self;
            };
        });

        mkPkgs = pkgs: extraOverlays: import pkgs {
          inherit system;
          config.allowUnfree = true;
          # config.cudaSupport = true;
          overlays = extraOverlays ++ (lib.attrValues self.overlays);
        };

        pkgs  = mkPkgs nixpkgs [ self.overlay ];
        unstable = mkPkgs nixpkgs-unstable [];

    in {
        lib = lib.custom;

        overlay = final: prev: {
            inherit unstable;
            user = self.packages.${system};
            devenv = devenv.packages.${system}.devenv;
        };

        overlays = mapModules ./overlays import;

        packages.${system} = mapModules ./packages (p: pkgs.callPackage p {});

        nixosModules = { dotfiles = import ./.; } // mapModulesRec ./modules import;

        nixosConfigurations = mapHosts ./hosts { inherit system; };

        devShell.${system} = import ./shell.nix { inherit pkgs; };

    };
}
