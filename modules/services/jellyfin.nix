{ options, config, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.services.jellyfin;
in {
    options.modules.services.jellyfin = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        services.jellyfin.enable = true;

        networking.firewall = {
            allowedTCPPorts = [ 8096 ];
            allowedUDPPorts = [ 8096 ];
        };

        user.extraGroups = [ "jellyfin" ];
    };
}
