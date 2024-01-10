{ config, pkgs, lib, inputs, ... }:
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
    };

    services.udev = {
        packages = with pkgs; [ gnome.gnome-settings-daemon ];
    };

    services.blueman.enable = true;

    services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts."astora" = {
            root = "/var/www/astora";
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
