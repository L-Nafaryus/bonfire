# self.devShells.${system}
#
{
  self,
  nixpkgs,
  ...
}: let
  forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux"];
  nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
in
  forAllSystems (system: let
    environment = rec {
      pkgs = nixpkgsFor.${system};

      bonfire = self;
      bonfire-lib = self.lib;
      bonfire-pkgs = self.packages.${system};

      crane = self.inputs.crane;
      crane-lib = self.inputs.crane.mkLib pkgs;
    };
  in {
    default = import ./bonfire.nix environment;

    netgen = import ./netgen.nix environment;

    openfoam = import ./openfoam.nix environment;

    rust = import ./rust.nix environment;
    rust-x11 = import ./rust-x11.nix environment;

    go = import ./go.nix environment;
  })
