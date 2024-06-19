{ 
    bonfire,
    lib, 
    pkgs,
    ...
}:
let 
    version = bonfire.shortRev or bonfire.dirtyShortRev or "unknown";
    projectPath = ../../.;
    modulesPath = ../../nixosModules;

    links = [
        { 
            hostname = "vcs-elnafo"; 
            url = "https://vcs.elnafo.ru/L-Nafaryus/bonfire/blob/master";
        }
        {
            hostname = "github";
            url = "https://github.com/L-Nafaryus/bonfire/blob/master";
        }
    ];

    formatDeclaration = declaration: 
        if lib.hasPrefix (toString modulesPath) (toString declaration) then 
            let subpath = lib.removePrefix (toString projectPath + "/") (toString declaration);
            in map ({ hostname, url }: { 
                url = "${url}/${subpath}"; 
                name = "<${hostname}:bonfire/${subpath}>"; 
            }) links
        else 
            # skip external declarations 
            lib.singleton declaration;

    nixosModules = (import modulesPath { inherit lib; check = false; });

    evaluatedModules = lib.evalModules {
        modules = nixosModules.modules ++ [ nixosModules.configModule ];
    };

    optionsDoc = pkgs.nixosOptionsDoc {
        options = builtins.removeAttrs evaluatedModules.options [
            "_module"
            "system"
        ];

        transformOptions = option: option // {
            declarations = lib.unique ( 
                lib.flatten (map (declaration: formatDeclaration declaration) option.declarations) ++
                option.declarations
            );
        };
        documentType = "none";
        revision = version;
    };

    systems = builtins.attrNames bonfire.packages;
    derivations = lib.flatten (
        map (packages: (
            map (name: packages.${name}) (builtins.attrNames packages)
        )) (map (system: bonfire.packages.${system}) systems));

    renderMaintainers = maintainers: lib.concatStringsSep ", " (
        let 
            maintainer = mt: if mt?github then "[${mt.name}](https://github.com/${mt.github})" else mt.name;
            email = mt: if mt?email then "<[${mt.email}](mailto:${mt.email})>" else "";
        in map (mt: maintainer mt + email mt) maintainers
    );

    renderPlatforms = platforms: if platforms != lib.platforms.none then 
        if platforms == lib.platforms.all then 
            "all"
        else 
            lib.concatStringsSep ", " (map (platform: "__${platform}__") platforms)
    else "";

    renderPackage = drv: ''
        ## ${drv.pname}
    
        ${lib.optionalString (drv.meta?description) drv.meta.description}
        
        ${lib.optionalString (drv.meta?homepage) "[Homepage](${drv.meta.homepage})"}

        Version: __${drv.version}__

        ${lib.optionalString (drv.meta?license) "License: [${drv.meta.license.fullName}](${drv.meta.license.url})"}

        Outputs: ${lib.concatStringsSep ", " (map (o: "__${o}__") drv.outputs)}

        ${lib.optionalString (drv.meta?mainProgram) "Provided programs: __${drv.meta.mainProgram}__"}

        ${lib.optionalString (drv.meta?maintainers) "Maintainers: ${renderMaintainers drv.meta.maintainers}"}

        ${lib.optionalString (drv.meta?platforms) "Platforms: ${renderPlatforms drv.meta.platforms}"}
    '';

    renderImage = drv: ''
        ## ${drv.imageName}

        ${lib.optionalString (drv.meta?description) drv.meta.description}
        
        ${lib.optionalString (drv.meta?homepage) "[Homepage](${drv.meta.homepage})"}

        Tag: __${drv.imageTag}__

        ${lib.optionalString (drv.fromImage != null) "From: __${drv.fromImage.imageName}__"}

        ${lib.optionalString (drv.meta?license) "License: ${if lib.isList drv.meta.license then (map (license: "[${drv.meta.license.fullName}](${drv.meta.license.url})") drv.meta.license) else "[${drv.meta.license.fullName}](${drv.meta.license.url})"}"}

        ${lib.optionalString (drv.meta?maintainers) "Maintainers: ${renderMaintainers drv.meta.maintainers}"}

        ${lib.optionalString (drv.meta?platforms) "Platforms: ${renderPlatforms drv.meta.platforms}"}
    '';

    packagesDoc = pkgs.writeText "packages.md"
        (lib.concatStringsSep "\n" (map (drv: 
            if drv?imageTag then renderImage drv else renderPackage drv) derivations));
    
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

    nativeBuildInputs = [ pkgs.mdbook ];
    dontPatch = true;
    dontConfigure = true;
    doCheck = false;

    buildPhase = ''
        runHook preBuild
        ln -s ${../../README.md} src/README.md
        ln -s ${optionsDoc.optionsCommonMark} src/options/modules.md
        ln -s ${packagesDoc} src/packages/packages.md
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
            runtimeInputs = [ pkgs.python3 ];
            text = "python -m http.server --bind 127.0.0.1"; 
        };
    };

    meta = with lib; {
        description = "Bonfire HTML documentation.";
        license = licenses.mit;
        maintainers = with bonfire.lib.maintainers; [ L-Nafaryus ];
        platforms = lib.platforms.all;
    };
}

