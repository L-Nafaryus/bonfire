{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.shell.taskwarrior;
in {
    options.modules.shell.taskwarrior = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        user.packages = [ pkgs.taskwarrior ];
    };
}
