{ config, pkgs, lib, inputs, self, ... }:
rec {
    system.stateVersion = "23.11";

    imports = [ 
        ./hardware.nix ./users.nix 
        ./services/papermc.nix
        ./services/gitea.nix
    ];

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
            enable = false;
            autoSuspend = false;
        };
        desktopManager.gnome.enable = false;
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
        enable = true;
        openFirewall = true;
    };

    services.spoofdpi.enable = true;

    #services.btrbk = {
    #    instances."catarina" = {
    #        onCalendar = "weekly";
    #        settings = {
    #            volume."/" = {
    #                
    #            };
    #        };
    #    };
    #};

# Packages
    environment.systemPackages = with pkgs; [
        wget

        ntfs3g
        sshfs
        exfat
        btrfs-progs

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
            User l.nafaryus
    '';

    programs.direnv.enable = true;

    fonts.packages = with pkgs; [ nerdfonts ];

}
