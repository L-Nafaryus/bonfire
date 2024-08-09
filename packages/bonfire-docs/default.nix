{
  bonLib,
  bonModules,
  self,
  lib,
  pkgs,
  ...
}: let
  version = "unknown";

  nixosModulesDoc = import ./nixosModulesDoc.nix {
    inherit lib pkgs version;

    modules = bonModules;
    root = ../../.;
    declarations = [
      {
        name = "elnafo-vcs";
        url = "https://vcs.elnafo.ru/L-Nafaryus/bonfire/src/branch/master";
      }
      {
        name = "github";
        url = "https://github.com/L-Nafaryus/bonfire/blob/master";
      }
    ];
    projectName = "bonfire";
    modulesPrefix = ../../nixosModules;
  };

  packagesDoc = import ./packagesDoc.nix {
    inherit lib pkgs;

    packages = self.packages;
    repoUrl = "https://vcs.elnafo.ru/L-Nafaryus/bonfire/src/branch/master";
    hydraUrl = "https://hydra.elnafo.ru/job/bonfire/master";
  };
in
  pkgs.stdenvNoCC.mkDerivation {
    pname = "bonfire-docs";
    inherit version;

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./src
        ./book.toml
        ./theme
      ];
    };

    nativeBuildInputs = [pkgs.mdbook];
    dontPatch = true;
    dontConfigure = true;
    doCheck = false;

    buildPhase = let
      nixosModulesDocsList = map (module_: "ln -s ${module_.commonMarkdown} src/nixosModules/${module_.name}.md") nixosModulesDoc.documentation;
      packageDocsList = map (package_: "ln -s ${package_.commonMarkdown} src/packages/${package_.name}.md") packagesDoc.documentation;
    in ''
      runHook preBuild

      ln -s ${../../README.md} src/README.md

      ${lib.concatStringsSep "\n" nixosModulesDocsList}
      substituteInPlace src/SUMMARY.md --replace '{{nixosModulesSummary}}' '${lib.concatStringsSep "\n" nixosModulesDoc.summary}'

      ${lib.concatStringsSep "\n" packageDocsList}
      substituteInPlace src/SUMMARY.md --replace '{{packagesSummary}}' '${lib.concatStringsSep "\n" packagesDoc.summary}'

      mdbook build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mv book $out
      runHook postInstall
    '';

    passthru = {
      serve = pkgs.writeShellApplication {
        name = "server";
        runtimeInputs = [pkgs.python3];
        text = "python -m http.server --bind 127.0.0.1";
      };
    };

    meta = with lib; {
      description = "Bonfire documentation.";
      license = licenses.mit;
      maintainers = with bonLib.maintainers; [L-Nafaryus];
      platforms = lib.platforms.all;
    };
  }
