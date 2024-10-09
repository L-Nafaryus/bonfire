{
  config,
  lib,
  pkgs,
  ...
}: {
  services.conduit = {
    enable = true;
    settings.global = {
      allow_registration = true;
      server_name = "elnafo.ru";
      address = "127.0.0.1";
      database_backend = "sqlite";
      well_known.client = "https://matrix.elnafo.ru";
      well_known.server = "matrix.elnafo.ru:443";
      turn_uris = ["turn:elnafo.ru?transport=udp" "turn:elnafo.ru?transport=tcp"];
    };
    turn_secret_file = config.sops.secrets.turn-secret.path;
  };

  services.nginx = {
    virtualHosts."matrix.elnafo.ru" = {
      forceSSL = true;
      http2 = true;
      useACMEHost = "elnafo.ru";
      locations."/" = {
        proxyPass = "http://127.0.0.1:6167";
        extraConfig = ''
          proxy_http_version 1.0;
          client_max_body_size 50M;
        '';
      };
    };
    virtualHosts."element.elnafo.ru" = {
      forceSSL = true;
      http2 = true;
      useACMEHost = "elnafo.ru";
      root = pkgs.element-web.override {
        conf = {
          default_theme = "dark";
          default_server_name = "matrix.elnafo.ru";
          brand = "Elnafo Matrix";
          permalink_prefix = "https://element.elnafo.ru";
        };
      };
    };
    virtualHosts."matrix-federation" = {
      serverName = "elnafo.ru";
      forceSSL = true;
      useACMEHost = "elnafo.ru";
      listen = [
        {
          port = 8448;
          addr = "0.0.0.0";
          ssl = true;
        }
        {
          port = 443;
          addr = "0.0.0.0";
          ssl = true;
        }
      ];
      locations."~ ^/(_matrix|.well_known)" = {
        proxyPass = "http://127.0.0.1:6167";
        extraConfig = ''
          proxy_http_version 1.0;
          client_max_body_size 50M;
        '';
      };
    };
  };

  services.coturn = rec {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets.coturn-secret.path;
    realm = "elnafo.ru";
    cert = "${config.security.acme.certs."elnafo.ru".directory}/full.pem";
    pkey = "${config.security.acme.certs."elnafo.ru".directory}/key.pem";
    extraConfig = ''
      # for debugging
      verbose
      # ban private IP ranges
      no-multicast-peers

    '';
  };

  networking.firewall = {
    allowedUDPPortRanges = lib.singleton {
      from = config.services.coturn.min-port;
      to = config.services.coturn.max-port;
    };
    allowedUDPPorts = [3478 5349];
    allowedTCPPorts = [8448 3478 5349];
  };
}
