{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    devCfg = config.modules.dev;
    cfg = devCfg.lua;
in {
    options.modules.dev.lua = {
        enable = mkBoolOpt false;
        xdg.enable = mkBoolOpt devCfg.enableXDG;
    };

    config = mkMerge [
        (mkIf cfg.enable {
            user.packages = with pkgs; [
                lua
                luaPackages.moonscript
            ];
        })

        (mkIf cfg.xdg.enable {
            # TODO
        })
    ];
}
