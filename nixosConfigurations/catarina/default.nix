{ config, pkgs, lib, self, ... }:
let bonfire-pkgs = self.packages.${pkgs.system};
in {
    system.stateVersion = "23.11";

    imports = [ 
        ./hardware.nix 
        ./users.nix 
        ./services/papermc.nix
        ./services/gitea.nix
    ];

# Nix settings
    nix = {
        settings = {
            experimental-features = [ "nix-command" "flakes" ];
            trusted-users = [ "l-nafaryus" ];
            allowed-users = [ "l-nafaryus" ];
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
            lego = bonfire-pkgs.lego; 
        };
    };

# Services
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
        settings.KbdInteractiveAuthentication = false;
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
        defaults.email = "l.nafaryus@elnafo.ru";
        defaults.group = "nginx";

        certs = {
            "elnafo.ru" = {
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

        clientMaxBodySize = "5G";

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

            "media.elnafo.ru" = {
                forceSSL = true;
                useACMEHost = "elnafo.ru";
                http2 = true;
                locations."/".proxyPass = "http://127.0.0.1:8096";
            };
        };
    };

    mailserver = {
        enable = true;
        fqdn = "elnafo.ru";
        domains = [ "elnafo.ru" ];

        certificateScheme = "acme-nginx";
        enableImapSsl = true;
        openFirewall = true;
        localDnsResolver = true;
        
        loginAccounts = import ../../.secrets/mail-recipients.nix { inherit config; };
    };

    services.jellyfin = {
        enable = false;
        openFirewall = true;
    };

    services.spoofdpi.enable = true;

    services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = [ "/" ];
    };

    services.btrbk = {
        instances."catarina" = {
            onCalendar = "daily";

            settings = {
                snapshot_preserve_min = "2d";
                snapshot_preserve = "14d";
                snapshot_dir = "/media/btrbk-snapshots";
                target_preserve_min = "no";
                target_preserve = "14d 8w *m";

                volume."/" = {
                    target = "/media/btrbk-backups";
                    subvolume = {
                        "var/lib/gitea" = {};
                        "var/lib/postgresql" = {};
                        "var/lib/postfix" = {};
                        "var/vmail" = {};
                    };
                };
            };
        };
    };

    services.transmission = {
        enable = true;
        openRPCPort = true;
        settings = {
            rpc-bind-address = "0.0.0.0";
            rpc-whitelist = "127.0.0.1,192.168.156.101";
            download-dir = "/media/storage/downloads";
            incomplete-dir = "/media/storage/downloads/incomplete";
        };
    };

    services.oscuro = {
        enable = true;
        discordTokenFile = config.sops.secrets.discordToken.path;
    };

    virtualisation = {
        containers.enable = true;
        podman = {
            enable = true;
            dockerCompat = true;
            defaultNetwork.settings.dns_enabled = true;
        };
    };

# Packages
    environment.systemPackages = with pkgs; [
        wget

        ntfs3g
        sshfs
        exfat
        btrfs-progs
        btrbk

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
            User l-nafaryus 

        Host catarina
            HostName 192.168.156.102
            Port 22
            User l-nafaryus
    '';

    programs.direnv.enable = true;
}
