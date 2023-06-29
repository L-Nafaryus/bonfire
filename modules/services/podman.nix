{ config, options, pkgs, lib, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.services.podman;
in {
    options.modules.services.podman = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        virtualisation = {
            podman = {
                enable = true;
                # Create a `docker` alias for podman, to use it as a drop-in replacement
                dockerCompat = true;
                # Required for containers under podman-compose to be able to talk to each other.
                defaultNetwork.settings.dns_enabled = true;
            };
            oci-containers = {
                backend = "podman";
                containers = {
                    container-name = {
                        image = "container-image";
                        autoStart = true;
                        ports = [ "127.0.0.1:1234:1234" ];
                    };
                };
            };
        };

    };
}
