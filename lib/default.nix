{lib, ...}: rec {
  maintainers = import ./maintainers.nix;

  moduleName = path:
    if builtins.baseNameOf (toString path) == "default.nix"
    then builtins.baseNameOf (lib.removeSuffix "/default.nix" (toString path))
    else builtins.baseNameOf (lib.removeSuffix ".nix" (toString path));

  moduleNames = pathList: map (path: moduleName path) pathList;

  importModules = pathList: map (path: import path) pathList;

  importNamedModules = pathList:
    lib.listToAttrs (
      lib.zipListsWith (name: value: {inherit name value;}) (moduleNames pathList) (importModules pathList)
    );
}
