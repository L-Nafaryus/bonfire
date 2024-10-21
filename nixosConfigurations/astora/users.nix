{
  config,
  pkgs,
  lib,
  bonPkgs,
  bonLib,
  inputs,
  ...
}: let
  user = "l-nafaryus";
in {
  # Users
  users.users.l-nafaryus = {
    isNormalUser = true;
    description = "L-Nafaryus";
    extraGroups = ["networkmanager" "wheel" "audio" "libvirtd" "input" "video" "disk" "wireshark"];
    group = "users";
    uid = 1000;
    initialPassword = "nixos";
    shell = pkgs.fish;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hmbackup";

  home-manager.users.${user} = {pkgs, ...}: let
    hmConfig = config.home-manager.users.${user};
  in {
    home.stateVersion = "23.11";
    home.username = "l-nafaryus";
    home.homeDirectory = "/home/l-nafaryus";
    imports = [
      (bonLib.injectArgs {
        inherit hmConfig;
      })
      inputs.catppuccin.homeManagerModules.catppuccin
      inputs.ags.homeManagerModules.default
      bonLib.preconfiguredModules.homeManager.hyprland
    ];

    home.packages = with pkgs; [
      taskwarrior3

      gparted

      firefox
      thunderbird

      pipewire.jack # pw-jack
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
      aeolus
      grandorgue

      qbittorrent
      transmission_3-qt
      telegram-desktop

      onlyoffice-bin

      jdk
      bonPkgs.ultimmc

      steamtinkerlaunch

      dunst
      libnotify
      # btop
      lua
      # bat
      mangohud
      gamescope
      libstrangle
      tree
      bonPkgs.bonvim

      freenect

      mpc-cli

      kdePackages.kmail

      flacon
      picard
    ];

    # Theme
    catppuccin = {
      # global, for all enabled programs
      enable = true;
      flavor = "macchiato";
      accent = "green";
    };

    gtk = {
      enable = true;
      # TODO: fix catppuccin deprecation. Provide Paper icons to gtk and gnomeShell manually. (+ regreet)
      catppuccin = {
        enable = true;
        accent = "green";
        flavor = "macchiato";
        gnomeShellTheme = true;
        icon = {
          enable = true;
          accent = "green";
          flavor = "macchiato";
        };
      };
    };

    programs = {
      # General
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
        '';
        plugins = with pkgs.fishPlugins;
          map (p: {
            name = p.pname;
            src = p.src;
          }) [
            fzf-fish
            tide
            grc
            hydro
          ];
        functions = {
          fish-theme-configure = ''
            tide configure \
                --auto \
                --style=Lean \
                --prompt_colors='True color' \
                --show_time='12-hour format' \
                --lean_prompt_height='Two lines' \
                --prompt_connection=Disconnected \
                --prompt_spacing=Compact \
                --icons='Many icons' \
                --transient=No
          '';
        };
      };

      git = {
        enable = true;
        lfs.enable = true;
        userName = "L-Nafaryus";
        userEmail = "l.nafaryus@gmail.com";
        signing = {
          key = "86F1EA98B48FFB19";
          signByDefault = true;
        };
        extraConfig = {
          # ignore trends
          init.defaultBranch = "master";
          core = {
            quotePath = false;
            commitGraph = true;
            whitespace = "trailing-space";
          };
          receive.advertisePushOptions = true;
          gc.writeCommitGraph = true;
          diff.submodule = "log";
        };
        aliases = {
          plog = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        };
      };

      # TODO: bat cannot determine catppuccin theme
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
        # TODO: replace existing ssh key with gpg provided
      };

      nnn = {
        enable = true;
        package = pkgs.nnn.override {withNerdIcons = true;};
        bookmarks = {
          d = "~/Downloads";
          p = "~/projects";
          i = "~/Pictures";
          m = "~/Music";
          v = "~/Videos";
        };
        plugins = {
          src = "${hmConfig.programs.nnn.finalPackage}/share/plugins";
          mappings = {
            # TODO: add used programs for previews with FIFO support
            p = "preview-tui";
          };
        };
      };

      ncmpcpp.enable = true;

      # Graphical

      wezterm = {
        enable = true;
        package = inputs.wezterm.packages.x86_64-linux.default;
        extraConfig = ''
          return {
              color_scheme = "Catppuccin Macchiato",
              default_prog = { "fish" },
              font_size = 10.0,
              enable_tab_bar = true,
              hide_tab_bar_if_only_one_tab = true,
              term = "wezterm",
              window_padding = {
                  left = 0,
                  right = 0,
                  top = 0,
                  bottom = 0
              },
              -- ISSUE: the terminal does not update after some time of use. It only updates with mouse movements. [Wayland, Hyprland]
              enable_wayland = false
          }
        '';
      };

      rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        terminal = "${lib.getExe hmConfig.programs.wezterm.package}";
        cycle = true;
        extraConfig = {
          show-icons = true;
          disable-history = false;
        };
        theme = let
          inherit (hmConfig.lib.formats.rasi) mkLiteral;
        in {
          "*" = {
            border-col = mkLiteral "#a6da95";
          };
          window = {
            border-radius = mkLiteral "5px";
          };
          # TODO: make window bigger, for 2k monitor, yeah
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

      mpv = {
        enable = true;
        # TODO: check ImPlay for packaging, it's may be better alternative to pure mpv
      };
    };

    services = {
      # General
      gpg-agent = {
        enable = true;
        defaultCacheTtl = 3600;
        defaultCacheTtlSsh = 3600;
        enableSshSupport = true;
        pinentryPackage = pkgs.pinentry-gtk2;
        enableFishIntegration = true;
        enableBashIntegration = true;
      };

      #mpd = {
      #  enable = true;
      #};

      # TODO: meet mpdris2 with system mpd
      #mpdris2 = {
      #  enable = true;
      #};
    };
    # Graphical

    # XDG
    xdg = {
      enable = true;
      mime.enable = true;
      userDirs.enable = true;
    };

    # dconf
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };

    home.sessionVariables = {
      HYPRSHOT_DIR = "${hmConfig.xdg.userDirs.pictures}/screenshots";
    };
  };

  environment.variables = let
    makePluginPath = name:
      (lib.makeSearchPath name [
        "/etc/profiles/per-user/$USER/lib"
        "/run/current-system/sw/lib"
        "$HOME/.nix-profile/lib"
      ])
      + ":$HOME/.${name}";
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

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Services
  services.spoofdpi.enable = true;

  services.zapret = {
    enable = true;
    mode = "nfqws";
    firewallType = "iptables";
    disableIpv6 = true;
    settings = ''
      MODE_HTTP=1
      MODE_HTTP_KEEPALIVE=0
      MODE_HTTPS=1
      MODE_QUIC=1
      MODE_FILTER=ipset
      TPWS_OPT="--split-http-req=method --split-pos=1 --oob"
      NFQWS_OPT_DESYNC="--dpi-desync=fake --dpi-desync-ttl=5"
      NFQWS_OPT_DESYNC_HTTP="--dpi-desync=fake --dpi-desync-ttl=5"
      NFQWS_OPT_DESYNC_HTTPS="--dpi-desync=fake --dpi-desync-ttl=5"
      NFQWS_OPT_DESYNC_QUIC="--dpi-desync=fake --dpi-desync-ttl=5"
      INIT_APPLY_FW=1
    '';
    filterAddressesSource = "https://antifilter.network/download/ipsmart.lst";
  };

  # TODO: remember who use gvfs
  services.gvfs.enable = true;

  services.mpd = {
    enable = true;
    musicDirectory = "/media/vault/audio/music";
    network.listenAddress = "any";
    network.startWhenNeeded = true;
    user = "l-nafaryus";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }
    '';
  };

  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
    XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.l-nafaryus.uid}";
  };

  programs.kdeconnect = {
    enable = true;
    package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;
  };

  programs.direnv.enable = true;

  fonts.packages = with pkgs; [nerdfonts liberation_ttf];

  programs.steam.enable = true;
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
}
