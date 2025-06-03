{
  config,
  pkgs,
  ...
}: {
  services.garage = {
    enable = true;
    package = pkgs.garage;
    settings = {
      data_dir = "/var/lib/garage/data";
      db_engine = "sqlite";
      replication_factor = 1;
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";
      rpc_secret_file = config.sops.secrets."garage/rpc-secret".path;
      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage.localhost";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage.localhost";
        index = "index.html";
      };
      admin = {
        api_bind_addr = "[::]:3903";
        admin_token_file = config.sops.secrets."garage/admin-token".path;
        metrics_token_file = config.sops.secrets."garage/metrics-token".path;
      };
    };
  };

  users.users.garage = {
    description = "Garage S3";
    home = config.services.garage.settings.data_dir;
    createHome = true;
    useDefaultShell = true;
    group = "garage";
    isSystemUser = true;
  };
  users.groups.garage = {};

  systemd.services.garage.serviceConfig = {
    User = "garage";
    WorkingDirectory = config.services.garage.settings.data_dir;
    DynamicUser = false;
  };

  services.nginx = {
    virtualHosts."s3.elnafo.ru" = {
      forceSSL = true;
      http2 = true;
      useACMEHost = "elnafo.ru";
      locations."^~ /public/" = {
        proxyPass = "http://127.0.0.1:3902";
        extraConfig = ''
          rewrite ^/public/(.*)$ /$1 break;
          proxy_http_version 1.0;
          proxy_set_header Host public;
          # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_max_temp_file_size 0;
          client_max_body_size 5G;
        '';
      };
    };
    virtualHosts."s3-api.elnafo.ru" = {
      forceSSL = true;
      http2 = true;
      useACMEHost = "elnafo.ru";
      locations."/" = {
        proxyPass = "http://127.0.0.1:3900";
        extraConfig = ''
          proxy_http_version 1.0;
          proxy_set_header Host $host;
          # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_max_temp_file_size 0;
          client_max_body_size 5G;
        '';
      };
    };
  };
}
