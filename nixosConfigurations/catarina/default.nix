{ config, pkgs, lib, inputs, self, ... }:
rec {
    system.stateVersion = "23.11";

    imports = [ ./hardware.nix ./users.nix ];

# Nix settings
    nix = {
        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            trusted-users = [ "nafaryus" ];
            allowed-users = [ "nafaryus" ];
            substituters = [ "https://nix-community.cachix.org" ];
            trusted-public-keys = [ 
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" 
            ];
            auto-optimise-store = true;
        };
        gc = {
            automatic = lib.mkDefault true;
            dates = lib.mkDefault "weekly";
            options = lib.mkDefault "--delete-older-than 14d";
        };
    };

# Nix packages
    nixpkgs = {
        hostPlatform = lib.mkDefault "x86_64-linux";
        config.allowUnfree = true;
        config.cudaSupport = false;
        config.packageOverrides = super: {
            lego = self.packages.${pkgs.system}.lego; 
        };
    };

# Services
    services.xserver = {
        enable = true;
 
        layout = "us";
        xkbVariant = "";
 
        videoDrivers = [ "nvidia" ];

        displayManager.gdm = {
            enable = true;
            autoSuspend = false;
        };
        desktopManager.gnome.enable = true;
        windowManager.awesome.enable = true;
    };

    services.printing.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };

    services.openssh = {
        enable = true;
        startWhenNeeded = true;
        settings.PasswordAuthentication = false;
    };

    services.udev = {
        packages = with pkgs; [ gnome.gnome-settings-daemon ];
    };

    services.blueman.enable = true;

    services.fail2ban = {
        enable = true;
        maxretry = 12;
        ignoreIP = [
            "192.168.0.0/16"
        ];
        bantime = "3h";
        bantime-increment = {
            enable = true; 
            multipliers = "1 2 4 8 16 32 64";
            maxtime = "168h"; 
            overalljails = true; 
        };
    };

    sops = {
        defaultSopsFile = ../../.secrets/secrets.yaml;
        age.keyFile = "/var/lib/secrets/sops-nix/catarina.txt";
        secrets = import ../../.secrets/sops-secrets.nix;
    };

    security.acme = {
        acceptTerms = true;
        defaults.email = "l.nafaryus@gmail.com";
        defaults.group = "nginx";

        certs = {
            "elnafo.ru" = {
                domain = "elnafo.ru";
                extraDomainNames = [ "*.elnafo.ru" ];
                dnsProvider = "webnames";
                credentialsFile = config.sops.secrets."dns".path;
                webroot = null;
            };
        };
    };

    services.nginx = {
        enable = true;

        package = pkgs.nginx.override { withMail = true; };

        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedTlsSettings = true; 

        virtualHosts = {
            "elnafo.ru" = {
                forceSSL = true;
                enableACME = true;
                root = "/var/www";
            };

            "www.elnafo.ru" = {
                forceSSL = true;
                useACMEHost = "elnafo.ru";
                globalRedirect = "elnafo.ru";
            };

            "vcs.elnafo.ru" = {
                forceSSL = true;
                useACMEHost = "elnafo.ru";
                locations."/".proxyPass = "http://127.0.0.1:3001";
            };

            "media.elnafo.ru" = {
                forceSSL = true;
                useACMEHost = "elnafo.ru";
                http2 = true;
                locations."/".proxyPass = "http://127.0.0.1:8096";
            };
        };

        
    };

    services.postgresql = {
        enable = true;
        authentication = ''
            # Type      Database    DB-User     Auth-Method     Ident-Map(optional)
            local       git         all         ident           map=gitea-users
        '';
        identMap = ''
            # MapName       System-User     DB-User
            gitea-users     git           git
        '';
        ensureDatabases = [ "git" ];
    };

    services.gitea = {
        enable = true;

        user = "git";
        group = "gitea";
        stateDir = "/var/lib/gitea";

        settings = {
            server = {
                DOMAIN = "vcs.elnafo.ru";
                ROOT_URL = "https://vcs.elnafo.ru/";
                HTTP_ADDRESS = "127.0.0.1";
                HTTP_PORT = 3001;
            };

            session.COOKIE_SECURE = true;

            mailer = {
                ENABLED = true;
                FROM = "git@elnafo.ru";
                PROTOCOL = "smtps";
                SMTP_ADDR = "smtp.elnafo.ru";
                SMTP_PORT = 465;
                USER = "git";
                USE_CLIENT_CERT = true;
                CLIENT_CERT_FILE = "${config.security.acme.certs."elnafo.ru".directory}/cert.pem";
                CLIENT_KEY_FILE = "${config.security.acme.certs."elnafo.ru".directory}/key.pem";
            };

            service.DISABLE_REGISTRATION = true;

            other = {
                SHOW_FOOTER_VERSION = false;
                SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
            };
        };

        mailerPasswordFile = config.sops.secrets."gitea/mail".path;

        database = {
            type = "postgres";
            passwordFile = config.sops.secrets."database/git".path;
            name = "git";
            user = "git";
        };

        lfs.enable = true;

        appName = "Elnafo VCS";
    };

    users.users.${services.gitea.user} = {
        description = "Gitea Service";
        home = services.gitea.stateDir;
        useDefaultShell = true;
        group = services.gitea.group;
        extraGroups = [ "nginx" ];
        isSystemUser = true;
    };

    mailserver = {
        enable = true;
        fqdn = "elnafo.ru";
        domains = [ "elnafo.ru" ];

        certificateScheme = "acme-nginx";
        enableImapSsl = true;
        openFirewall = true;
        
        loginAccounts = import ../../.secrets/mail-recipients.nix { inherit config; };
    };

    services.jellyfin = {
        enable = true;
        openFirewall = true;
    };

    services.minecraft-server = {
        enable = true;
        eula = true;
        declarative = true;
        openFirewall = true;
        serverProperties = {
            server-port = 25565;
            gamemode = "survival";
            motd = "NixOS Minecraft Server";
            max-players = 10;
            level-seed = "66666666";
            enable-status = true;
            enforce-secure-profile = false;
            difficulty = "normal";
            online-mode = false;
        };
    };

    services.spoofdpi.enable = true;

# Packages
    environment.systemPackages = with pkgs; [
        wget

        ntfs3g
        sshfs
        exfat

        lm_sensors

        git
        ripgrep
        fd
        lazygit
        unzip

        gnumake

        fishPlugins.fzf-fish
        fishPlugins.tide
        fishPlugins.grc
        fishPlugins.hydro

        nnn
        fzf
        grc

        gcc

        cachix

        gnupg
        nnn
        htop
    ];

    programs = {
        fish.enable = true;

        neovim = {
          enable = true;
          defaultEditor = true;
        };
    };

    programs.ssh.extraConfig = ''
        Host astora
            HostName 192.168.156.101
            Port 22
            User nafaryus 

        Host catarina
            HostName 192.168.156.102
            Port 22
            User nafaryus
    '';

    programs.direnv.enable = true;

    fonts.packages = with pkgs; [ nerdfonts ];

}
