{ pkgs, lib, ... }:
{
    system.stateVersion = "23.11";

    imports = [ ./hardware.nix ./users.nix ];

# Nix settings
    nix = {
        settings = {
            experimental-features = [ "nix-command" "flakes" "repl-flake" ];
            trusted-users = [ "l-nafaryus" ];
            allowed-users = [ "l-nafaryus" ];
            substituters = [ "https://nix-community.cachix.org" ];
            trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
            auto-optimise-store = true;
        };
        gc = {
            automatic = lib.mkDefault true;
            dates = lib.mkDefault "weekly";
            options = lib.mkDefault "--delete-older-than 7d";
        };
    };

# Nix packages
    nixpkgs = {
        hostPlatform = lib.mkDefault "x86_64-linux";
        config.allowUnfree = true;
        config.cudaSupport = false;

        overlays = [
            (final: prev: {
                blender = prev.blender.override { cudaSupport = true; };
            })
        ];
    };

# Services
    services.xserver = {
        enable = true;
 
        xkb = {
            layout = "us";
            variant = "";
        };
 
        videoDrivers = [ "nvidia" ];

        displayManager.gdm = {
            enable = true;
            autoSuspend = false;
        };
        desktopManager.gnome.enable = true;
        windowManager.awesome.enable = true;

        wacom.enable = true;
    };

    services.printing.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
    };

    services.openssh = {
        enable = true;
        startWhenNeeded = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
    };

    services.udev = {
        packages = with pkgs; [ gnome.gnome-settings-daemon ];
        extraRules = ''
            KERNEL=="rtc0", GROUP="audio"
            KERNEL=="hpet", GROUP="audio"
        '';
    };

    services.blueman.enable = true;

    services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = [ "/" ];
    };

# Packages
    environment.systemPackages = with pkgs; [
        wget

        parted
        ntfs3g
        sshfs
        exfat

        lm_sensors

        git
        git-lfs
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

    fonts.packages = with pkgs; [ nerdfonts ];

    programs.steam.enable = true;
    systemd.extraConfig = "DefaultLimitNOFILE=1048576";

    virtualisation = {
        containers.enable = true;
        podman = {
            enable = true;
            dockerCompat = true;
            defaultNetwork.settings.dns_enabled = true;
        };
        libvirtd.enable = true;
    };
}
