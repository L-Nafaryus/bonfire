{ config, pkgs, lib, inputs, self, ... }:
{
# Users
    users.users.l-nafaryus = {
        isNormalUser = true;
        description = "L-Nafaryus";
        extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" ];
        group = "users";
        uid = 1000;
        initialPassword = "nixos";
        shell = pkgs.fish;
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.l-nafaryus = { pkgs, ... }: {
        home.stateVersion = "23.11";
        home.username = "l-nafaryus";
        home.homeDirectory = "/home/l-nafaryus";
        home.packages = with pkgs; [
            gnupg
            git
            nnn
            htop
            pass 
            taskwarrior
            tmux

            gparted

            gnomeExtensions.appindicator
            gnomeExtensions.vitals
            xclip

            firefox
            thunderbird

            discord

            pipewire.jack                   # pw-jack
            carla
            qpwgraph
            wireplumber
            yabridge
            yabridgectl

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
            olive-editor
            openshot-qt
            musescore
            # soundux                       # unmaintained
            losslesscut-bin
            yt-dlp
            ffmpeg

            calf
            zynaddsubfx
            lsp-plugins
            x42-plugins
            cardinal
            gxplugins-lv2
            xtuner
            aether-lv2

            obs-studio
            obs-studio-plugins.obs-vkcapture
            obs-studio-plugins.input-overlay
            obs-studio-plugins.obs-pipewire-audio-capture

            qbittorrent
            transmission-qt

            onlyoffice-bin

            jdk
            self.packages.${pkgs.system}.ultimmc

            liberation_ttf

            steamtinkerlaunch


        ];
        
        xdg = {
            enable = true;
            mime.enable = true;
        };

        dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
                autoconnect = [ "qemu:///system" ];
                uris = [ "qemu:///system" ];
            };
        };

        home.file = {
            ".config/gnupg/gpg-agent.conf".text = ''
                default-cache-ttl 3600
                pinentry-program ${pkgs.pinentry.gtk2}/bin/pinentry
            '';

            ".config/git/config".source = "${config.bonfire.configDir}/git/config";
            
            ".config/nvim" = { 
                source = "${config.bonfire.configDir}/nvim"; 
                recursive = true; 
            };
        };
    };

    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-gnome3;
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

    systemd.user.extraConfig = "DefaultLimitNOFILE=524288";

    programs.virt-manager.enable = true;


    
# Services
    services.spoofdpi.enable = true;
}
