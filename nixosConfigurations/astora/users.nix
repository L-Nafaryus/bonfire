{ config, pkgs, lib, inputs, self, ... }:
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
            gnomeExtensions.vitals
            xclip

            firefox
            thunderbird

            discord

            carla
            qpwgraph
            wireplumber

            lutris
            wine
            winetricks
            gamemode

            vlc
            lollypop
            gimp
            inkscape
            imagemagick
            blender
            ardour

            calf
            zynaddsubfx
            lsp-plugins
            x42-plugins

            obs-studio
            obs-studio-plugins.obs-vkcapture
            obs-studio-plugins.input-overlay
            obs-studio-plugins.obs-pipewire-audio-capture

            qbittorrent

            onlyoffice-bin

            anydesk

            jdk
            self.packages.${pkgs.system}.ultimmc
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

    environment.variables = let 
        makePluginPath = name: (lib.makeSearchPath name [ 
            "/etc/profiles/per-user/$USER/lib"
            "/run/current-system/sw/lib" 
            "$HOME/.nix-profile/lib" 
        ]) + ":$HOME/.${name}";
    in {
        LADSPA_PATH = makePluginPath "ladspa";
        LV2_PATH = makePluginPath "lv2";
        VST_PATH = makePluginPath "vst";
        VST3_PATH = makePluginPath "vst3";
    };

# Services
    services.spoofdpi.enable = true;
}
