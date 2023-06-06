{ config, options, lib, pkgs, ... }:
with builtins;
with lib;
with lib.custom;
let
    cfg = config.modules.X.Y;
in {
    options.modules.X.Y = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {

    };
}
