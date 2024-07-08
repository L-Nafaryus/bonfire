{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) stdenv fetchurl;

  playerlist = [
    {
      name = "L_Nafaryus";
      uuid = "02c47438-79eb-3938-b5e0-d7c03cb5709f";
      level = 4;
    }
    {
      name = "AfroPriest";
      uuid = "6fa9251d-11a5-33ad-ada3-312f0632eab1";
      level = 3;
    }
    {
      name = "DiAlteri";
      uuid = "0a278f5c-7192-30c8-aa2f-af157c348009";
      level = 3;
    }
  ];

  operators = lib.filter (player: player.level > 0) playerlist;
  whitelist = map (player: removeAttrs player ["level"]) playerlist;

  # Plugins

  passky = stdenv.mkDerivation rec {
    pname = "Passky";
    version = "2.1.1";
    src = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/Black1_TV/Passky/versions/${version}/PAPER/Passky-${version}.jar";
      hash = "sha256-D5NpFrkGLgZNMS5WlMRM3Uv07hPsI9Hdsii2whTAZ2o=";
    };
    meta.homepage = "https://hangar.papermc.io/Black1_TV/Passky";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  grimAnticheat = stdenv.mkDerivation rec {
    pname = "GrimAC";
    version = "2.3.46";
    src = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/GrimAnticheat/GrimAnticheat/versions/${version}/PAPER/grimac-${version}.jar";
      hash = "sha256-tG8pBDMU4N/Ijn5RfdsQrtY4/gEhN1wEDCopqOSIqB4=";
    };
    meta.homepage = "https://hangar.papermc.io/GrimAnticheat/GrimAnticheat";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  viaVersion = stdenv.mkDerivation rec {
    pname = "ViaVersion";
    version = "4.9.2";
    src = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/${version}/PAPER/ViaVersion-${version}.jar";
      hash = "sha256-dvcyqCpIjArKCnUAD/L+lG/5gRQ9fLMKcl/+o8sLmYs=";
    };
    meta.homepage = "https://hangar.papermc.io/ViaVersion/ViaVersion";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  directionHUD = stdenv.mkDerivation rec {
    pname = "DirectionHUD";
    version = "1.2.2";
    src = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/other/DirectionHUD/versions/${version}%2B1.18-1.20.2/PAPER/directionhud-spigot-${version}%2B1.18-1.20.2.jar";
      hash = "sha256-F+86Q58+3VoqNoD8P38bu8u1Hx8Si0lxNXZnF/R4hAg=";
    };
    meta.homepage = "https://hangar.papermc.io/other/DirectionHUD";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  miniMOTD = stdenv.mkDerivation rec {
    pname = "MiniMOTD";
    version = "2.0.14";
    src = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/jmp/MiniMOTD/versions/${version}/PAPER/minimotd-bukkit-${version}.jar";
      hash = "sha256-d7l/pZGxteS2A9c9PIZASDTACGev8HY5SHZRvcxBc5A=";
    };
    meta.homepage = "https://hangar.papermc.io/jmp/MiniMOTD";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  skinsRestorer = stdenv.mkDerivation rec {
    pname = "SkinsRestorer";
    version = "15.0.2";
    src = fetchurl {
      url = "https://github.com/SkinsRestorer/SkinsRestorerX/releases/download/${version}/SkinsRestorer.jar";
      hash = "sha256-fhAegFtl22xKXMi5MbsXCYOjbfqOlQTnILoEJxCDbkc=";
    };
    meta.homepage = "https://hangar.papermc.io/SRTeam/SkinsRestorer";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  squaremap = stdenv.mkDerivation rec {
    pname = "squaremap";
    version = "1.2.2";
    src = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/jmp/squaremap/versions/${version}/PAPER/squaremap-paper-mc1.20.2-${version}.jar";
      hash = "sha256-Z8AWzZLlZavF8YYs1kslhtCvzq5fZ7O97mTx3hCgj78=";
    };
    meta.homepage = "https://hangar.papermc.io/jmp/squaremap";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  stargate = stdenv.mkDerivation rec {
    pname = "Stargate";
    version = "0.11.5.6";
    src = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/Stargate/Stargate/versions/${version}/PAPER/Stargate-${version}.jar";
      hash = "sha256-Ilz0z3juQ9c4/pUnHnvJO+PnJF1+vXBxW2pbERuEBo4=";
    };
    meta.homepage = "https://hangar.papermc.io/Stargate/Stargate";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  chunky = stdenv.mkDerivation rec {
    pname = "Chunky";
    version = "1.3.92";
    src = fetchurl {
      url = "https://hangarcdn.papermc.io/plugins/pop4959/Chunky/versions/${version}/PAPER/Chunky-${version}.jar";
      hash = "sha256-ABHfKJK0LQI2ZLt1D83897RAnE9xWu6+34IOlwTh17w=";
    };
    meta.homepage = "https://hangar.papermc.io/pop4959/Chunky";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  xclaim = stdenv.mkDerivation rec {
    pname = "XClaim";
    version = "1.11.0";
    src = fetchurl {
      url = "https://github.com/WasabiThumb/xclaim/releases/download/${version}/xclaim-${version}.jar";
      hash = "sha256-49R9cj1NnOx9n0yBtOj+m4V+56P4Ko/Co/LOgdhd2y4=";
    };
    meta.homepage = "https://hangar.papermc.io/WasabiThumbs/XClaim";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/${pname}.jar
    '';
  };

  plugins = [
    passky
    grimAnticheat
    viaVersion
    directionHUD
    miniMOTD
    skinsRestorer
    squaremap
    stargate
    chunky
    xclaim
  ];
in {
  services.papermc = {
    enable = true;
    eula = true;
    openFirewall = true;
    serverProperties = {
      server-port = 25565;
      gamemode = "survival";
      motd = "GoodOmens";
      max-players = 10;
      level-seed = "66666666";
      enable-status = true;
      enforce-secure-profile = false;
      difficulty = "normal";
      online-mode = false;
      enable-rcon = true;
      "rcon.port" = 25600;
      white-list = false;
    };
    jvmOpts = "-Xms512M -Xmx2048M";
    rconPasswordFile = config.sops.secrets."papermc/rcon".path;
    whitelist = whitelist;
    ops = operators;
    extraPreStart =
      ''
        mkdir -p ${builtins.concatStringsSep " " (map (v: "plugins/${v.pname}") plugins)}
      ''
      + builtins.concatStringsSep "\n" (map (v: "ln -sf ${v.outPath}/bin/${v.pname}.jar plugins/") plugins)
      + ''

        ln -sf ${config.bonfire.configDir}/goodomens/plugins/MiniMOTD/main.conf plugins/MiniMOTD/
        mkdir -p plugins/MiniMOTD/icons
        ln -sf ${config.bonfire.configDir}/goodomens/plugins/MiniMOTD/icons/goodomens-logo.png plugins/MiniMOTD/icons/
        ln -sf ${config.bonfire.configDir}/goodomens/plugins/Tablist/config.yml plugins/Tablist/
        ln -sf ${config.bonfire.configDir}/goodomens/plugins/squaremap/config.yml plugins/squaremap/
        ln -sf ${config.bonfire.configDir}/goodomens/plugins/squaremap/advanced.yml plugins/squaremap/
        ln -sf ${config.bonfire.configDir}/goodomens/plugins/squaremap/advanced.yml plugins/squaremap/
        ln -sf ${config.bonfire.configDir}/goodomens/site/map/index.html plugins/squaremap/web/
      '';
  };

  services.nginx.virtualHosts."mc.elnafo.ru" = {
    forceSSL = true;
    useACMEHost = "elnafo.ru";
    locations."/".root = "/var/www/goodomens";
    locations."^~ /map/".proxyPass = "http://127.0.0.1:8088/";
    locations."/gallery/".root = "/var/www/goodomens";
    locations."/gallery/images/" = {
      root = "/var/www/goodomens";
      extraConfig = ''autoindex on;'';
    };
  };
}
