{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    devCfg = config.modules.dev;
    cfg = devCfg.shell;
in {
    options.modules.dev.shell = {
        enable = mkBoolOpt false;
        xdg.enable = mkBoolOpt devCfg.xdg.enable;
    };

    config = mkMerge [
        (mkIf cfg.enable {
            user.packages = with pkgs; [
                shellcheck
            ];
        })

        (mkIf cfg.xdg.enable {
            # TODO
        })
    ];
}
