{
  lib,
  bonLib,
  self,
  check ? true,
  ...
}: let
  moduleList = [
    ./misc/bonfire/default.nix
    ./services/papermc.nix
    ./services/qbittorrent-nox.nix
    ./services/spoofdpi.nix
    # ISSUE: collision with nixos module zapret
    #./services/zapret.nix
    ./services/conduit.nix
  ];

  configModule = {
    config,
    pkgs,
    ...
  }: {
    config = {
      # module type checking
      _module.check = check;
      # extra arguments
      _module.args = {
        bonPkgs = self.packages.${pkgs.system};
        bonLib = lib.mkDefault bonLib;
      };
    };
  };

  importedModules =
    map (path: {...}: {
      # imports provide path for each module needed for documentation
      # inject module configuration
      imports = [path configModule];
    })
    moduleList;

  importedModuleNames = map (path: bonLib.nameFromPath path) moduleList;

  bonfireModule = {
    config,
    pkgs,
    ...
  }: {
    # collect all modules
    imports = moduleList ++ [configModule];
  };
in
  lib.listToAttrs (
    lib.zipListsWith (name: value: {inherit name value;}) importedModuleNames importedModules
  )
  // {
    bonfire = bonfireModule;
    default = bonfireModule;
  }
