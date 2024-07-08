{
  description = "Basic rust template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    crane,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux"];
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    packages = forAllSystems (system: {
      my-crate = let
        pkgs = nixpkgsFor.${system};
        craneLib = crane.lib.${system};
      in
        craneLib.buildPackage {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          strictDeps = true;

          buildInputs = [];
        };

      default = self.packages.${system}.my-crate;
    });

    checks = forAllSystems (system: {
      inherit (self.packages.${system}.my-crate);

      my-crate-fmt = let
        craneLib = crane.lib.${system};
      in
        craneLib.cargoFmt {
          src = craneLib.cleanCargoSource (craneLib.path ./.);
        };
    });

    apps = forAllSystems (system: {
      default = {
        type = "app";
        program = "${self.packages.${system}.my-crate}/bin/rust-example";
      };
    });

    devShells = forAllSystems (system: {
      default = crane.lib.${system}.devShell {
        checks = self.checks.${system};

        packages = [];
      };
    });
  };
}
