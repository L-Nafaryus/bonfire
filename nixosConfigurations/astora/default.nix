{ config, pkgs, lib, agenix, inputs, ... }:
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
            trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
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
    };

# Services
    services.xserver = {
        enable = true;
 
        layout = "us";
        xkbVariant = "";
 
        videoDrivers = [ "nvidia" ];

        displayManager.gdm.enable = true;
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
    };

    services.openssh = {
        enable = true;
        startWhenNeeded = true;
    };

    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

    services.blueman.enable = true;

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

        fzf
        grc

        gcc

        cachix
        inputs.agenix.packages.${system}.default

        helix
    ];

    programs = {
        fish.enable = true;

        neovim = {
          enable = true;
          defaultEditor = true;
        };
    };

    programs.direnv.enable = true;

    fonts.packages = with pkgs; [ nerdfonts ];

    programs.steam.enable = true;
    systemd.extraConfig = "DefaultLimitNOFILE=1048576";
}
