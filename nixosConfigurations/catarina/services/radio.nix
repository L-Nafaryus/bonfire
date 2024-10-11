{config, ...}: {
  containers = {
    radio-synthwave = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.231.136.1";
      localAddress = "10.231.136.2";

      bindMounts = {
        "/var/lib/music" = {
          hostPath = "/home/l-nafaryus/Music";
          isReadOnly = true;
        };
      };

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

      bindMounts = {
        "/var/lib/music" = {
          hostPath = "/home/l-nafaryus/Music";
          isReadOnly = true;
        };
      };

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
        host = "10.231.136.2";
        port = 6600;
        url = "https://radio.elnafo.ru/synthwave";
        status = "Receive";
        genre = "synthwave, dark synthwave";
      }
      {
        id = "non-stop-pop";
        name = "Non-Stop-Pop";
        host = "10.231.136.3";
        port = 6601;
        url = "https://radio.elnafo.ru/non-stop-pop";
        status = "Online";
        location = "Los Santos";
        genre = "pop, r&b, dance music";
      }
    ];
  };

  services.nginx.virtualHosts."radio.elnafo.ru" = {
    forceSSL = true;
    useACMEHost = "elnafo.ru";
    locations."/".proxyPass = "http://127.0.0.1:54605";
    locations."/synthwave".proxyPass = "http://10.231.136.2:6660";
    locations."/non-stop-pop".proxyPass = "http://10.231.136.3:6661";
  };
}
