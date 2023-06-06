{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    devCfg = config.modules.dev;
    cfg = devCfg.common-lisp;
in {
    options.modules.dev.common-lisp = {
        enable = mkBoolOpt false;
        xdg.enable = mkBoolOpt devCfg.xdg.enable;
    };

    config = mkMerge [
        (mkIf cfg.enable {
            user.packages = with pkgs; [
                sbcl
                lispPackages.quicklisp
            ];
        })

        (mkIf cfg.xdg.enable {
            # TODO
        })
    ];
}
