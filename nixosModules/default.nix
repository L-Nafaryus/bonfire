{ lib, check ? true, self, ... }:
rec {
    modules = [
        ./misc/bonfire/default.nix 
        ./services/papermc.nix
        ./services/qbittorrent-nox.nix
        ./services/spoofdpi.nix
    ];

    configModule = { config, pkgs, ... }: {

        config = {
            # Module type checking
            _module.check = check;
            #_module.args.baseModules = modules;
            #_module.args.pkgs = lib.mkDefault pkgs;
            _module.args.bonpkgs = self.packages.${pkgs.system};
        };
    };
}
