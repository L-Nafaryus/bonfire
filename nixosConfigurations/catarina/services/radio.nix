{config, ...}: {
  services.mpd = {
    enable = true;
    musicDirectory = "/home/l-nafaryus/Music";
    network.listenAddress = "any";
    network.startWhenNeeded = true;
    user = "l-nafaryus";
    extraConfig = ''
      audio_output {
        type "httpd"
        name "Radio"
        port "6666"
        bind_to_address "127.0.0.1"
        encoder "lame"
        max_clients "0"
        website "https://radio.elnafo.ru"
        always_on "yes"
        tags "yes"
        bitrate "128"
        format "44100:16:1"
      }
    '';
  };

  services.nginx.virtualHosts."radio.elnafo.ru" = {
    forceSSL = true;
    useACMEHost = "elnafo.ru";
    locations."/synthwave".proxyPass = "http://127.0.0.1:6666";
  };

  networking.firewall.allowedTCPPorts = [config.services.mpd.network.port];
}
