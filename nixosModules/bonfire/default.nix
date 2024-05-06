{ self, ... }:
{ config, lib, ... }:
with lib; 
let cfg = config.bonfire;
in {
    options= {
        bonfire = {
            home = mkOption { 
                type = types.path; 
                default = ../../.;
                description = "Bonfire root directory";
            };
            
            configDir = mkOption { 
                type = types.path; 
                default = "${cfg.home}/config"; 
                description = "Path to Bonfire static configuration files";
            };

            withSecrets = mkOption {
                type = types.bool;
                default = false;
                description = "Enables the Bonfire secrets";
            };

            secrets = mkOption {
                type = types.attrs;
                default = {};
            };
        };
    };

    config = {
        assertions = mkIf cfg.withSecrets [{ 
            assertion = (builtins.pathExists ./secrets/default.nix);
            message = "Missed git submodule 'bonfire-secrets'";
        }];

        environment.sessionVariables = {
            BONFIRE_HOME = cfg.home;
        };

        bonfire.secrets = mkIf cfg.withSecrets (import ./secrets { inherit config; });
    };
}
