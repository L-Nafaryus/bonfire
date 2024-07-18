{
  config,
  pkgs,
  lib,
  bonPkgs,
  inputs,
  ...
}: {
  # Users
  users.users.l-nafaryus = {
    isNormalUser = true;
    description = "L-Nafaryus";
    extraGroups = ["networkmanager" "wheel" "audio" "libvirtd" "input"];
    group = "users";
    uid = 1000;
    initialPassword = "nixos";
    shell = pkgs.fish;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hmbackup";

  home-manager.users.l-nafaryus = {pkgs, ...}: let
    hmConfig = config.home-manager.users.l-nafaryus;
  in {
    home.stateVersion = "23.11";
    home.username = "l-nafaryus";
    home.homeDirectory = "/home/l-nafaryus";
    imports = [
      inputs.catppuccin.homeManagerModules.catppuccin
      inputs.ags.homeManagerModules.default
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

      (firefox.override {nativeMessagingHosts = [passff-host];})
      thunderbird

      discord

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
      (python3.withPackages (p: [p.click]))
      mangohud
      gamescope
      libstrangle
      webcord
      wl-clipboard
      cliphist
      tree
      bonPkgs.bonvim
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

    # Theme
    catppuccin = {
      # global, for all enabled programs
      enable = true;
      flavor = "macchiato";
      accent = "green";
    };

    gtk = {
      enable = true;
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

      # Graphical

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
        theme = let
          inherit (hmConfig.lib.formats.rasi) mkLiteral;
        in {
          "*" = {
            border-col = mkLiteral "#a6da95";
          };
          window = {
            border-radius = mkLiteral "5px";
          };
        };
      };
      ags = {
        enable = true;
        extraPackages = with pkgs; [
          libdbusmenu-gtk3 # for system tray
        ];
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

      # Graphical
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

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Devices (use `hyprctl devices`)
        "$monitor1" = "AOC Q27G2G3R3B 137P4HA000540";
        "$monitor2" = "AOC Q27B3MA 17ZPAHA006135";
        "$keyboard" = "keychron-keychron-k3-pro";
        "$mouse" = "logitech-g102-lightsync-gaming-mouse";

        # Main programs
        "$terminal" = "${lib.getExe hmConfig.programs.alacritty.package}";
        "$menu" = "${lib.getExe hmConfig.programs.rofi.package} -show drun";
        "$fileManager" = "$terminal -e ${lib.getExe pkgs.nnn}";

        monitor = [
          "desc:$monitor2, 2560x1440@75, 0x0, auto"
          "desc:$monitor1, 2560x1440@165, 2560x0, auto"
          "Unknown-1, disable"
        ];

        exec-once = [
          "eww daemon"
          "nm-applet --indicator &"
          "blueman-applet &"
          "wl-gammarelay-rs run &"
          "systemctl --user start hypridle"
          "wl-paste --type text --watch cliphist store" #Stores only text data
          "wl-paste --type image --watch cliphist store" #Stores only image data
          "swww-daemon & swww img ~/Pictures/wallpapers/emily-in-the-cyberpunk-city.3840x2160.png & swww img ~/Pictures/wallpapers/emily-in-the-cyberpunk-city.3840x2160a.gif"
        ];

        env = [
          "XCURSOR_SIZE,16"
          "HYPRCURSOR_SIZE,16"
          "WLR_DRM_NO_ATOMIC,1"
        ];

        general = {
          gaps_in = 2;
          gaps_out = 2;

          border_size = 2;

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = true;

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = true;

          layout = "dwindle";
        };
        decoration = {
          rounding = 5;

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 0.95;

          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
            enabled = true;
            size = 3;
            passes = 1;

            vibrancy = 0.1696;
          };
        };
        animations = {
          enabled = true;

          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle = {
          pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true; # You probably want this
        };

        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        master = {
          new_status = "master";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc = {
          force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false; # Enable the random hyprland logo / anime girl background. :)
        };
        input = {
          kb_layout = "us,ru";

          follow_mouse = 1;

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

          touchpad = {
            natural_scroll = false;
          };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#gestures
        gestures = {
          workspace_swipe = false;
        };

        windowrulev2 = [
          "suppressevent maximize, class:.*" # You'll probably like this.
          "float, class:^(steam_app.*)$"
          "immediate, class:^(steam_app.*)$"
          "float, class:^(steam_proton.*)$"
        ];
        bind = [
          "SUPER, Q, exec, $terminal"
          "SUPER, N, exec, $fileManager"
          "SUPER, R, exec, $menu"
          "SUPER, P, exec, eww open --toggle basemenu"

          "SUPER, C, killactive,"
          "SUPER, M, exit,"
          "SUPER, V, togglefloating,"
          "SUPER, F, fullscreen,"
          "SUPER, J, togglesplit," # dwindle

          # Move focus with mainMod + arrow keys
          "SUPER, left, movefocus, l"
          "SUPER, right, movefocus, r"
          "SUPER, up, movefocus, u"
          "SUPER, down, movefocus, d"

          # Switch workspaces with mainMod + [0-9]
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"
          "SUPER, 0, workspace, 10"

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "SUPER SHIFT, 1, movetoworkspace, 1"
          "SUPER SHIFT, 2, movetoworkspace, 2"
          "SUPER SHIFT, 3, movetoworkspace, 3"
          "SUPER SHIFT, 4, movetoworkspace, 4"
          "SUPER SHIFT, 5, movetoworkspace, 5"
          "SUPER SHIFT, 6, movetoworkspace, 6"
          "SUPER SHIFT, 7, movetoworkspace, 7"
          "SUPER SHIFT, 8, movetoworkspace, 8"
          "SUPER SHIFT, 9, movetoworkspace, 9"
          "SUPER SHIFT, 0, movetoworkspace, 10"

          # special workspace (scratchpad)
          "SUPER, S, togglespecialworkspace, magic"
          "SUPER SHIFT, S, movetoworkspace, special:magic"

          "SUPER, SPACE, exec, hyprctl switchxkblayout keychron-keychron-k3-pro next"
          ", PRINT, exec, hyprshot -m region"
          "SUPER, H, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        ];
        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ];
        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86MonBrightnessDown, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -500"
          ", XF86MonBrightnessUp, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +500"
          "SUPER, XF86MonBrightnessDown, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay Brightness d -0.1"
          "SUPER, XF86MonBrightnessUp, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay Brightness d +0.1"
        ];
      };
    };

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

  # Services
  services.spoofdpi.enable = true;

  services.gvfs.enable = true;
}
