{ config, pkgs, ... }:
{
# Users
    users.users.nafaryus = {
        isNormalUser = true;
        description = "L-Nafaryus";
        extraGroups = [ "networkmanager" "wheel" ];
        group = "users";
        uid = 1000;
        initialPassword = "nixos";
        shell = pkgs.fish;
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    bonfire.enable = true;

    home-manager.users.nafaryus = { pkgs, ... }: {
        home.stateVersion = "23.11";
        home.username = "nafaryus";
        home.homeDirectory = "/home/nafaryus";
        home.packages = with pkgs; [
            gnupg
            git
            nnn
            htop

            gparted

            gnomeExtensions.appindicator
            xclip

            firefox
            thunderbird

            discord

            carla
            qpwgraph
            wireplumber

            gamemode

            gimp
            inkscape
            blender
            ardour
        ];
        
        xdg.enable = true;
        xdg.mime.enable = true;

        home.file.".config/gnupg/gpg-agent.conf".text = ''
            default-cache-ttl 3600
            pinentry-program ${pkgs.pinentry.gtk2}/bin/pinentry
        '';
        home.file.".config/git/config".source = "${config.bonfire.configDir}/git/config";
        home.file.".config/nvim" = { source = "${config.bonfire.configDir}/nvim"; recursive = true; };
    };

    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryFlavor = "curses";
    };
}
