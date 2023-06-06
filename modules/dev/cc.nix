{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    devCfg = config.modules.dev;
    cfg = devCfg.cc;
in {
    options.modules.dev.cc = {
          enable = mkBoolOpt false;
          xdg.enable = mkBoolOpt devCfg.xdg.enable;
    };

    config = mkMerge [
        (mkIf cfg.enable {
            user.packages = with pkgs; [
                clang
                gcc
                bear
                gdb
                cmake
                llvmPackages.libcxx
            ];
        })

        (mkIf cfg.xdg.enable {
            # TODO
        })
    ];
}
