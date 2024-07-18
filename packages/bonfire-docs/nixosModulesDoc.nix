{
  lib,
  pkgs,
  modules,
  excludedModules ? ["default"],
  root ? null,
  declarations ? {},
  projectName ? "",
  modulesPrefix ? "",
  version ? "unknown",
}: let
  moduleNames = lib.filter (key: builtins.all (restricted: key != restricted) excludedModules) (lib.attrNames modules);
  moduleValues = map (key: modules.${key}) moduleNames;

  genDeclaration = storeDeclaration: declarations:
    map (declaration: let
      subpath = lib.removePrefix (toString root + "/") (toString storeDeclaration);
      project =
        if projectName != ""
        then "${projectName}/"
        else "";
    in {
      name = "<${declaration.name}:${project}${subpath}>";
      url = "${declaration.url}/${subpath}";
    })
    declarations;

  formatDeclaration = storeDeclaration:
    if lib.hasPrefix (toString modulesPrefix) (toString storeDeclaration)
    then genDeclaration storeDeclaration declarations
    # skip external declarations
    else lib.singleton storeDeclaration;

  transformOptions = option:
    option
    // {
      declarations = lib.unique (
        lib.flatten (map (declaration: formatDeclaration declaration) option.declarations)
        ++ option.declarations
      );
    };

  genDocumentation = module:
    pkgs.nixosOptionsDoc {
      options = builtins.removeAttrs (lib.evalModules {modules = [module];}).options [
        "_module"
        "system"
      ];

      transformOptions = transformOptions;
      documentType = "none";
      revision = version;
    };
in {
  documentation =
    lib.zipListsWith (name: moduleDocumentation: {
      name = name;
      commonMarkdown = moduleDocumentation.optionsCommonMark;
    })
    moduleNames
    (map (module: genDocumentation module) moduleValues);

  summary = map (name: "  - [${name}](nixosModules/${name}.md)") moduleNames;
}
