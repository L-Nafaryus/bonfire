{ config, pkgs, lib, inputs, self, ... }:
{
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
        maxretry = 5;
        ignoreIP = [
            "192.168.0.0/16"
        ];
        bantime = "24h";
        bantime-increment = {
            enable = true; 
            multipliers = "1 2 4 8";
            maxtime = "168h"; 
            overalljails = true; 
        };
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
                credentialsFile = "/var/lib/secrets/certs.secret";
                group = "nginx";
                webroot = null;
            };
        };
    };

    services.nginx = {
        enable = true;

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
        };
    };

    services.postgresql = {
        enable = true;
        authentication = ''
            # Type      Database    DB-User     Auth-Method     Ident-Map(optional)
            local       gitea       all         ident           map=gitea-users
        '';
        identMap = ''
            # MapName       System-User     DB-User
            gitea-users     gitea           gitea
        '';
        ensureDatabases = [ "gitea" ];
    };

    services.gitea = {
        enable = true;

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
                FROM = "gitea@elnafo.ru";
            };

            service.DISABLE_REGISTRATION = true;

            other = {
                SHOW_FOOTER_VERSION = false;
                SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
            };
        };

        database = {
            type = "postgres";
            passwordFile = "/var/lib/secrets/gitea/gitea-dbpassword";
            name = "gitea";
            user = "gitea";
        };

        lfs.enable = true;

        appName = "Elnafo VCS";
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
