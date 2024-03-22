{ self, ... }:
{ config, lib, pkgs, ... }:
with lib; 
let 
    cfg = config.services.spoofdpi;
    pkg = self.packages.${pkgs.system}.spoofdpi;
in {
    options.services.spoofdpi = {
        enable = mkEnableOption "Enables the SpoofDPI service";
        
        address = mkOption rec { 
            type = types.str; 
            default = "127.0.0.1";
            example = default;
            description = "Listen address";
        };

        port = mkOption rec {
            type = types.port;
            default = 8080;
            example = default;
            description = "Port";
        };

        openFirewall = mkOption {
            type = types.bool;
            default = false;
            description = "Open services.spoofdpi.port";
        };

        dns = mkOption rec {
            type = types.str;
            default = "8.8.8.8";
            example = default;
            description = "DNS server";
        };
    };

    config = mkIf cfg.enable {
        systemd.services.spoofdpi = {
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];
            serviceConfig = {
                Restart = "on-failure";
                ExecStart = "${pkg}/bin/spoof-dpi -no-banner -addr ${cfg.address} -port ${toString cfg.port} -dns ${cfg.dns}";
                DynamicUser = "yes";
            };
        };

        networking.firewall = mkIf cfg.openFirewall {
            allowedTCPPorts = [ cfg.port ];
        };
    };
}
