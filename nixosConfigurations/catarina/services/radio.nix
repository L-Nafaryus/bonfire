{config, ...}: {
  containers.radio-synthwave = {
    autoStart = true;
    privateNetwork = true;

    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services.mpd = {
        enable = true;
        musicDirectory = "/home/l-nafaryus/Music";
        network.listenAddress = "any";
        #network.startWhenNeeded = true;
        user = "l-nafaryus";
        network.port = 6600;
        extraConfig = ''
          audio_output {
            type "httpd"
            name "Radio"
            port "6660"
            bind_to_address "127.0.0.1"
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

  services.nginx.virtualHosts."radio.elnafo.ru" = {
    forceSSL = true;
    useACMEHost = "elnafo.ru";
    locations."/synthwave".proxyPass = "http://127.0.0.1:6660";
  };

  networking.firewall.allowedTCPPorts = [6600];
}
