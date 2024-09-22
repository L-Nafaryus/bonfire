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

    radio-non-stop = {
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
              website "https://radio.elnafo.ru/non-stop"
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

  services.nginx.virtualHosts."radio.elnafo.ru" = {
    forceSSL = true;
    useACMEHost = "elnafo.ru";
    locations."/synthwave".proxyPass = "http://10.231.136.2:6660";
    locations."/non-stop".proxyPass = "http://10.231.136.3:6661";
  };
}
