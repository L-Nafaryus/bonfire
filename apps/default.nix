{
  self,
  nixpkgs,
  ...
}: let
  forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux"];
  nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
in
  forAllSystems (system: let
    pkgs = nixpkgsFor.${system};

    bonfire = self;
    bonfire-lib = self.lib;
    bonfire-pkgs = self.packages.${system};
  in {
  })
