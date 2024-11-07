{config, ...}: {
  containers = let 
    bindMounts = {
        "/var/lib/music" = {
          hostPath = "/media/storage/audio/library";
          isReadOnly = true;
        };
      };
  in {
    radio-synthwave = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.231.136.1";
      localAddress = "10.231.136.2";

      inherit bindMounts;

      config = {
        config,
        pkgs,
        lib,
        ...
      }: {
        services.mpd = {
          enable = true;
          musicDirectory = "/var/lib/music";
          network.listenAddress = "any";
          #network.startWhenNeeded = true;
          user = "mpd";
          network.port = 6600;
          extraConfig = ''
            audio_output {
              type "httpd"
              name "Radio"
              port "6660"
              encoder "lame"
              max_clients "0"
              website "https://radio.elnafo.ru/synthwave"
              always_on "yes"
              tags "yes"
              bitrate "128"
              format "44100:16:1"
            }
          '';
        };

        system.stateVersion = "24.05";

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [6600 6660];
        };
      };
    };

    radio-non-stop-pop = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.231.136.1";
      localAddress = "10.231.136.3";

      inherit bindMounts;

      config = {
        config,
        pkgs,
        lib,
        ...
      }: {
        services.mpd = {
          enable = true;
          musicDirectory = "/var/lib/music";
          network.listenAddress = "any";
          #network.startWhenNeeded = true;
          user = "mpd";
          network.port = 6601;
          extraConfig = ''
            audio_output {
              type "httpd"
              name "Radio"
              port "6661"
              encoder "lame"
              max_clients "0"
              website "https://radio.elnafo.ru/non-stop-pop"
              always_on "yes"
              tags "yes"
              bitrate "128"
              format "44100:16:1"
            }
          '';
        };

        system.stateVersion = "24.05";

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [6601 6661];
        };
      };
    };

    radio-hell-gates = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.231.136.1";
      localAddress = "10.231.136.4";

      inherit bindMounts;

      config = {
        config,
        pkgs,
        lib,
        ...
      }: {
        services.mpd = {
          enable = true;
          musicDirectory = "/var/lib/music";
          network.listenAddress = "any";
          #network.startWhenNeeded = true;
          user = "mpd";
          network.port = 6602;
          extraConfig = ''
            audio_output {
              type "httpd"
              name "Radio"
              port "6662"
              encoder "lame"
              max_clients "0"
              website "https://radio.elnafo.ru/hell-gates"
              always_on "yes"
              tags "yes"
              bitrate "128"
              format "44100:16:1"
            }
          '';
        };

        system.stateVersion = "24.05";

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [6602 6662];
        };
      };
    };
  };

  services.elnafo-radio = {
    enable = true;
    base = {
      title = "// Elnafo Radio //";
      meta = [
        ["author" "L-Nafaryus"]
        ["discord" "https://discord.gg/ZWUChw5wzm"]
        ["git" "https://vcs.elnafo.ru/L-Nafaryus/elnafo-radio"]
        ["matrix" "https://matrix.to/#/#elnafo:elnafo.ru"]
      ];
    };
    stations = [
      {
        id = "synthwave";
        name = "Synthwave";
        host = config.containers.radio-synthwave.localAddress;
        port = 6600;
        url = "https://radio.elnafo.ru/synthwave";
        status = "Receive";
        genre = "synthwave, dark synthwave";
      }
      {
        id = "non-stop-pop";
        name = "Non-Stop-Pop";
        host = config.containers.radio-non-stop-pop.localAddress;
        port = 6601;
        url = "https://radio.elnafo.ru/non-stop-pop";
        status = "Online";
        location = "Los Santos";
        genre = "pop, r&b, dance music";
      }
      {
        id = "hell-gates";
        name = "Hell Gates";
        host = config.containers.radio-hell-gates.localAddress;
        port = 6602;
        url = "https://radio.elnafo.ru/hell-gates";
        status = "Receive";
        genre = "melodic death metal, death metal, metalcore";
      }
    ];
  };

  services.nginx.virtualHosts."radio.elnafo.ru" = {
    forceSSL = true;
    useACMEHost = "elnafo.ru";
    locations."/".proxyPass = "http://${config.services.elnafo-radio.server.address}:${toString config.services.elnafo-radio.server.port}";
    locations."/synthwave".proxyPass = "http://${config.containers.radio-synthwave.localAddress}:6660";
    locations."/non-stop-pop".proxyPass = "http://${config.containers.radio-non-stop-pop.localAddress}:6661";
    locations."/hell-gates".proxyPass = "http://${config.containers.radio-hell-gates.localAddress}:6662";
  };
}
