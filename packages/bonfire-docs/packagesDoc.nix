{
  lib,
  pkgs,
  packages,
  excludedPackages ? ["default"],
  repoUrl ? null,
  hydraUrl ? null,
}: let
  supportedSystems = builtins.attrNames packages;

  derivations = lib.flatten (
    map (packages_: (
      map (name: packages_.${name}) (builtins.attrNames packages_)
    )) (map (system: packages.${system}) supportedSystems)
  );

  extractName = drv:
    if drv ? pname
    then drv.pname
    else if drv ? imageName
    then drv.imageName
    else "unknown";

  derivationNames = map (drv: extractName drv) derivations;

  genDocumentation = drv: let
    name = extractName drv;

    type =
      if drv ? pname
      then "package"
      else if drv ? imageTag
      then "image"
      else "unknown";

    description = lib.optionalString (drv.meta ? description) drv.meta.description;
    homepage = lib.optionalString (drv.meta ? homepage) "[Homepage](${drv.meta.homepage})";
    source = lib.optionalString (repoUrl != null) "[Source](${repoUrl}/packages/${name}/default.nix)";

    versionOrTag =
      if type == "package"
      then "Version: __${drv.version}__"
      else if type == "image"
      then "Tag: __${drv.imageTag}__"
      else "";

    license = lib.optionalString (drv.meta ? license) "License: ${
      if lib.isList drv.meta.license
      then
        lib.concatStringsSep ", " (map (license: let
          licenseName =
            if license.free
            then license.fullName
            else if license ? shortName
            then license.shortName
            else license.fullName;
        in
          if license ? url
          then "[${licenseName}](${license.url})"
          else licenseName)
        drv.meta.license)
      else "[${drv.meta.license.fullName}](${drv.meta.license.url})"
    }";

    maintainers = let
      maintainer = mt:
        if mt ? github
        then "[${mt.name}](https://github.com/${mt.github})"
        else mt.name;
      email = mt:
        if mt ? email
        then "<[${mt.email}](mailto:${mt.email})>"
        else "";
    in
      lib.optionalString (drv.meta ? maintainers) ("Maintainers: "
        + lib.concatStringsSep ", " (
          map (mt: maintainer mt + email mt) drv.meta.maintainers
        ));

    platforms = lib.optionalString (drv.meta ? platforms && drv.meta.platforms != lib.platforms.none) (
      let
        # limit package platforms to supported by flake only
        filteredPlatforms = lib.intersectLists drv.meta.platforms supportedSystems;
      in
        "Platforms: "
        + lib.concatStringsSep ", " (map (platform:
          if hydraUrl != null
          then "[${platform}](${hydraUrl}/packages.${platform}.${name})"
          else "__${platform}__")
        filteredPlatforms)
    );

    mainProgram = lib.optionalString (drv.meta ? mainProgram) "Main program: __${drv.meta.mainProgram}__";

    outputs = lib.optionalString (drv ? outputs) ("Outputs: " + lib.concatStringsSep ", " (map (o: "__${o}__") drv.outputs));

    fromImage = lib.optionalString (drv ? fromImage && drv.fromImage != null) "From: __${drv.fromImage.imageName}__";

    stats = let
      stats_ = [
        (lib.optionalString
          (drv.meta ? broken && drv.meta.broken)
          " _broken_")
        (lib.optionalString
          (drv.meta ? unfree && drv.meta.unfree)
          " _unfree_")
        (lib.optionalString
          (drv.meta ? unsupported && drv.meta.unsupported)
          " _unsupported_")
        (lib.optionalString
          (drv.meta ? insecure && drv.meta.insecure)
          " _insecure_")
      ];
    in
      lib.optionalString (builtins.any (s: s == true) stats_) "[ ${lib.concatStringsSep "," stats_} ]";
  in {
    commonMarkdown = pkgs.writeText "meta.md" ''
      ## ${name}

      ${stats}

      ${description}

      ${source} ${lib.optionalString (homepage != "") "| ${homepage}"}

      ${versionOrTag} ${fromImage}

      ${mainProgram}

      ${outputs}

      ${license}

      ${maintainers}

      ${platforms}
    '';
  };
in {
  documentation =
    lib.zipListsWith (name: packageDocumentation: {
      name = name;
      commonMarkdown = packageDocumentation.commonMarkdown;
    })
    derivationNames
    (map (drv: genDocumentation drv) derivations);

  summary = map (name: "  - [${name}](packages/${name}.md)") derivationNames;
}
