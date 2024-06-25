{ config, pkgs, lib, self, inputs, ... }:
{
# Users
    users.users.l-nafaryus = {
        isNormalUser = true;
        description = "L-Nafaryus";
        extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "input" ];
        group = "users";
        uid = 1000;
        initialPassword = "nixos";
        shell = pkgs.fish;
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hmbackup";

    home-manager.users.l-nafaryus = { pkgs, ... }: 
    let 
        hmConfig = config.home-manager.users.l-nafaryus; 
    in {
        home.stateVersion = "23.11";
        home.username = "l-nafaryus";
        home.homeDirectory = "/home/l-nafaryus";
        imports = [
            inputs.catppuccin.homeManagerModules.catppuccin
        ];
        home.packages = with pkgs; [
            #gnupg
            git
            nnn
            pass 
            taskwarrior
            #tmux

            gparted

            xclip

            (firefox.override { extraNativeMessagingHosts = [ passff-host ]; })
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



            qbittorrent
            transmission-qt
            telegram-desktop

            onlyoffice-bin

            jdk
            self.packages.${pkgs.system}.ultimmc

            liberation_ttf

            steamtinkerlaunch

            eww
            tor
            networkmanagerapplet
            #rofi-wayland
            kgx
            dunst
            libnotify
            playerctl
            wl-gammarelay-rs
            # btop
            lua
            # bat
            musikcube
            swww
            hyprshot
            (python3.withPackages (p: [ p.click ]))
            mangohud
            gamescope
            libstrangle
            webcord
            wl-clipboard
            cliphist
            tree 
        ];

        xdg.portal = {
            enable = true;
            configPackages = with pkgs; [
                #xdg-desktop-portal-wlr
                xdg-desktop-portal-hyprland
            ];
            extraPortals = with pkgs; [
                xdg-desktop-portal-gtk
            ];
        };
        
        catppuccin = {
            # global, for all enabled programs
            enable = true;
            flavor = "macchiato";
            accent = "green";
        };

        gtk = {
            enable = true;
            cursorTheme = {
                name = "Papirus-Dark";
                size = 16;
            };
        };

        programs = {
            fish = {
                enable = true;
                interactiveShellInit = ''
                    set fish_greeting
                '';
                plugins = with pkgs.fishPlugins; map (p: { name = p.pname; src = p.src; }) [
                    fzf-fish 
                    tide        # tide configure --auto --style=Lean --prompt_colors='True color' --show_time='12-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Many icons' --transient=No 
                    grc 
                    hydro
                ];
            };
            bat.enable = true;
            btop = {
                enable = true;
                settings = {
                    cpu_bottom = true;
                    proc_tree = true;
                };
            };
            fzf.enable = true;
            tmux.enable = true;
            lazygit.enable = true;
            gpg = {
                enable = true;
                homedir = "${hmConfig.xdg.configHome}/gnupg";
                mutableKeys = true;
                mutableTrust = true;
            };

            alacritty = {
                enable = true;
                settings = {
                    font = {
                        size = 10;
                    };
                };
            };
            rofi = {
                enable = true;
                package = pkgs.rofi-wayland;
                terminal = "${lib.getExe hmConfig.programs.alacritty.package}";
                cycle = true;
                extraConfig = {
                    show-icons = true;
                    disable-history = false;
                };
                theme = let inherit (hmConfig.lib.formats.rasi) mkLiteral; in {
                    "*" = {
                        border-col = mkLiteral "#a6da95";
                    };
                    window = {
                        border-radius = mkLiteral "5px";
                    };
                };
            };

            obs-studio = {
                enable = true;
                plugins = with pkgs.obs-studio-plugins; [
                    obs-vkcapture
                    input-overlay
                    obs-pipewire-audio-capture
                    wlrobs
                    inputs.obs-image-reaction.packages.${pkgs.system}.default
                ];
            };
        };

        services = {
            gpg-agent = {
                enable = true;
                defaultCacheTtl = 3600;
                defaultCacheTtlSsh = 3600;
                enableSshSupport = true;
                pinentryPackage = pkgs.pinentry-gtk2;
                enableFishIntegration = true;
                enableBashIntegration = true;
            };

            hypridle = {
                enable = true;
                settings = {
                    general = {
                        after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
                        ignore_dbus_inhibit = false;
                    };
                    listener = [
                        {
                            timeout = 300;
                            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
                            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
                        }
                    ];
                };
            };
        };

        # ---
        xdg = {
            enable = true;
            mime.enable = true;
            userDirs.enable = true;
        };

        dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
                autoconnect = [ "qemu:///system" ];
                uris = [ "qemu:///system" ];
            };
        };

        home.sessionVariables = {
            HYPRSHOT_DIR = "${hmConfig.xdg.userDirs.pictures}/screenshots";
        };

        home.file = {
            #"gnupg/gpg-agent.conf".text = ''
            #    default-cache-ttl 3600
            #    pinentry-program ${pkgs.pinentry.gtk2}/bin/pinentry
            #'';

            ".config/git/config".source = "${config.bonfire.configDir}/git/config";
            
            ".config/nvim" = { 
                source = "${config.bonfire.configDir}/nvim"; 
                recursive = true; 
            };
        };
    };

    #programs.gnupg.agent = {
    #    enable = true;
    #    enableSSHSupport = true;
    #    pinentryPackage = pkgs.pinentry-gnome3;
    #};

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

    environment.sessionVariables = {
        # hint electron applications to use wayland
        NIXOS_OZONE_WL = "1";
    };

    systemd.user.extraConfig = "DefaultLimitNOFILE=524288";

    programs.virt-manager.enable = true;


    
# Services
    services.spoofdpi.enable = true;
}
