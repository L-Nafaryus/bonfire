{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    devCfg = config.modules.dev;
    cfg = devCfg.rust;
in {
    options.modules.dev.rust = {
        enable = mkBoolOpt false;
        xdg.enable = mkBoolOpt devCfg.xdg.enable;
    };

    config = mkMerge [
        (mkIf cfg.enable {
            user.packages = [
                pkgs.rustup
            ];
            env.PATH = [ "$(${pkgs.yarn}/bin/yarn global bin)" ];
            environment.shellAliases = {
                rs  = "rustc";
                rsp = "rustup";
            };
        })

        (mkIf cfg.xdg.enable {
            env.RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
            env.CARGO_HOME = "$XDG_DATA_HOME/cargo";
            env.PATH = [ "$CARGO_HOME/bin" ];
        })
    ];
}
