{lib, ...}: rec {
  maintainers = import ./maintainers.nix;

  nameFromPath = path:
    if builtins.baseNameOf (toString path) == "default.nix"
    then builtins.baseNameOf (lib.removeSuffix "/default.nix" (toString path))
    else builtins.baseNameOf (lib.removeSuffix ".nix" (toString path));

  preconfiguredModules = lib.listToAttrs (map (path: {
      name = nameFromPath path;
      value = import path;
    })
    [
      ./preconfiguredModules/bonvim.nix
    ]);

  isBroken = derivation: derivation ? meta && derivation.meta ? broken && derivation.meta.broken;

  functionType = lib.types.mkOptionType {
    name = "function";
    check = value: builtins.isFunction value;
  };

  platformType = lib.types.mkOptionType {
    name = "platform";
    check = value: builtins.isString value && lib.any (v: v == value) lib.platforms.all;
  };

  packageType = with lib;
    types.submodule {
      options = {
        source = mkOption {
          type = types.oneOf [types.path functionType];
          description = "Path to file with expression to build derivation or expression";
        };
        platforms = mkOption {
          type = types.listOf platformType;
          description = "List of supported platforms";
        };
        builder = mkOption {
          type = functionType;
          description = "Function with platform specific inputs that call final build function";
          example = "{pkgs, ...}: pkgs.callPackage";
        };
        extraArgs = mkOption {
          type = types.attrs;
          default = {};
          description = "Extra arguments passed to builder inputs. Platform is not configured for this arguments";
        };
      };
    };

  packagesModuleOptions = {...}:
    with lib; {
      options = {
        packages = mkOption {
          type = types.attrsOf packageType;
          default = {};
          description = "Set of defined packages";
        };
      };
    };

  collectPackages = platformInputs: packagesAttrs: let
    packages =
      (lib.evalModules {
        modules = [
          packagesModuleOptions
          ({...}: {
            packages = packagesAttrs;
          })
        ];
      })
      .config
      .packages;
    packagesList = lib.attrsToList packages;

    evaluateDerivation = system: name: package: let
      platInputs =
        if functionType.check platformInputs
        then (platformInputs system) // package.extraArgs
        else throw "`plaformInputs` must be a function: `system` -> {...}";
      platformBuilder = package.builder platInputs;
      derivation = platformBuilder package.source platInputs;
    in {${name} = derivation;};

    evaluatedPackages = map ({
      name,
      value,
    }:
      lib.genAttrs value.platforms (
        system: evaluateDerivation system name value
      ))
    packagesList;
  in
    lib.mapAttrs (name: value: lib.mergeAttrsList value) (lib.zipAttrs evaluatedPackages);
}
