{ config, lib, ... }:
with lib; 
let cfg = config.bonfire;
in {
    options= {
        bonfire = {
            enable = mkEnableOption "Enables the Bonfire module";

            home = mkOption { 
                type = types.path; 
                default = ../.;
                description = "Bonfire root flake directory";
            };
            
            configDir = mkOption { 
                type = types.path; 
                default = "${config.bonfire.home}/config"; 
                description = "Path to directory with static configuration files";
            };
        };
    };

    config = mkIf cfg.enable {
        environment.sessionVariables = {
            BONFIRE_HOME = cfg.home;
        };
    };
}
