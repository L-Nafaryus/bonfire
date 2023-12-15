{ config, lib, ... }:
with lib; 
let cfg = config.bonfire;
in {
    options= {
        bonfire = {
            enable = mkOption { type = types.bool; default = false; };
            home = mkOption { type = types.path; default = ../.; };
            configDir = mkOption { type = types.path; default = "${config.bonfire.home}/config"; };
        };
    };

    config = mkIf cfg.enable {
        environment.sessionVariables = {
            BONFIRE_HOME = cfg.home;
        };
    };
}
