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
    extraGroups = ["networkmanager" "wheel" "audio" "libvirtd" "input" "video" "disk" "wireshark" "adbusers"];
    group = "users";
    uid = 1000;
    initialPassword = "nixos";
    shell = pkgs.nushell;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1YGp8AI48hJUSQBZpuKLpbj2+3Q09vq64NxFr0N1MS"
    ];
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
        inherit inputs;
      })
      inputs.catppuccin.homeModules.catppuccin
      inputs.ags.homeManagerModules.default
      #bonLib.preconfiguredModules.homeManager.hyprland
      ../common/hm/helix.nix
      ../common/hm/nushell.nix
      ../common/hm/zellij.nix
      ../common/hm/wezterm.nix
      ../common/hm/yazi.nix
    ];

    home.file = {
      ".config/nushell/modules" = {
        source = "${../common/hm/nu}";
        recursive = true;
      };
    };

    home.packages = with pkgs; [
      taskwarrior3

      gparted

      firefox
      thunderbird

      pipewire.jack # pw-jack
      carla
      qpwgraph
      wireplumber
      # yabridge
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

      #dunst
      #libnotify
      # btop
      # bat
      mangohud
      gamescope
      libstrangle
      tree
      bonPkgs.bonvim

      freenect

      mpc-cli

      kdePackages.kmail
      kdePackages.kmail-account-wizard
      kdePackages.krdc
      kdePackages.ksshaskpass

      flacon
      picard

      docker-compose
      podman-compose
      dive
      lazydocker

      # virtiofsd
      wl-clipboard

      ripgrep
      repgrep
      delta

      wl-gammarelay-rs

      rofi-wayland

      tdf
      tui-journal
      rustscan
      flamelens
      t-rec
      taskwarrior-tui
      trippy
      # oryx # add support
      ripgrep-all
      httm
      bluetui
      systemctl-tui
      iamb

      rose-pine-hyprcursor

      rclone
      ghostty
      chromium
      vscodium
    ];

    xdg.portal = {
      enable = true;
      configPackages = with pkgs; [
        xdg-desktop-portal-hyprland
        kdePackages.xdg-desktop-portal-kde
        tui-journal
      ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    services.dunst = {
      enable = true;
      settings = {
        global = {
          frame_color = "#d5c4a1";
          separator_color = "#d5c4a1";
        };

        base16_low = {
          msg_urgency = "low";
          background = "#3c3836";
          foreground = "#665c54";
        };

        base16_normal = {
          msg_urgency = "normal";
          background = "#504945";
          foreground = "#d5c4a1";
        };

        base16_critical = {
          msg_urgency = "critical";
          background = "#fb4934";
          foreground = "#ebdbb2";
        };
      };
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 300;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 4;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
            shadow_passes = 2;
          }
        ];
      };
    };

    services.hypridle = {
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

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = "ghostty";
        bindkeysToCode = true;
        keybindings = {
          "Mod4+r" = "exec nu -c 'use ~/.config/nushell/modules/mod.nu *; nurofi apps'";
          "Mod4+p" = "exec nu -c 'use ~/.config/nushell/modules/mod.nu *; nurofi powermenu'";
          "Mod4+q" = "exec ${lib.getExe hmConfig.programs.wezterm.package}";

          "Mod4+n" = "mode resize";
          "Mod4+c" = "kill";
          "Mod4+s" = "splith";
          "Mod4+v" = "splitv";
          "Mod4+f" = "fullscreen";
          "Mod4+l" = "exec ${pkgs.swaylock}/bin/swaylock -c 333333";

          "Mod4+Shift+space" = "floating toggle";
          "Mod4+Shift+minus" = "move scratchpad";
          "Mod4+minus" = "scratchpad show";

          "Mod4+Left" = "focus left";
          "Mod4+Right" = "focus right";
          "Mod4+Up" = "focus up";
          "Mod4+Down" = "focus down";

          "Mod4+Shift+Left" = "move left";
          "Mod4+Shift+Right" = "move right";
          "Mod4+Shift+Up" = "move up";
          "Mod4+Shift+Down" = "move down";

          "Mod4+1" = "workspace number 1";
          "Mod4+2" = "workspace number 2";
          "Mod4+3" = "workspace number 3";
          "Mod4+4" = "workspace number 4";
          "Mod4+5" = "workspace number 5";
          "Mod4+6" = "workspace number 6";
          "Mod4+7" = "workspace number 7";
          "Mod4+8" = "workspace number 8";
          "Mod4+9" = "workspace number 9";
          "Mod4+0" = "workspace number 10";

          "Mod4+Shift+1" = "move container to workspace number 1";
          "Mod4+Shift+2" = "move container to workspace number 2";
          "Mod4+Shift+3" = "move container to workspace number 3";
          "Mod4+Shift+4" = "move container to workspace number 4";
          "Mod4+Shift+5" = "move container to workspace number 5";
          "Mod4+Shift+6" = "move container to workspace number 6";
          "Mod4+Shift+7" = "move container to workspace number 7";
          "Mod4+Shift+8" = "move container to workspace number 8";
          "Mod4+Shift+9" = "move container to workspace number 9";
          "Mod4+Shift+0" = "move container to workspace number 10";

          "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86MonBrightnessDown" = "exec busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.1";
          "XF86MonBrightnessUp" = "exec busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d +0.1";
        };
        input = {
          "type:keyboard" = {
            xkb_layout = "us,ru";
            xkb_options = "grp:win_space_toggle";
          };
        };
        output = {
          "DP-3" = {
            mode = "2560x1440@74.968Hz";
          };
          "DP-2" = {
            mode = "2560x1440@165Hz";
            pos = "2560 0";
          };
          # "*".bg = "~/Pictures/wallpapers/current fill";
        };
        modes = {
          resize = {
            "Escape" = "mode default";
            "Left" = "resize grow left 10 px";
            "Right" = "resize grow right 10 px";
            "Up" = "resize grow height 10 px";
            "Down" = "resize grow height 10 px";
            "Shift+Right" = "resize shrink right 10 px";
            "Shift+Left" = "resize shrink left 10 px";
            "Shift+Up" = "resize shrink height 10 px";
            "Shift+Down" = "resize shrink height 10 px";
          };
        };
        bars = [
          {
            position = "top";
            # font = "pango:monospace 8.000000";
            mode = "dock";
            hidden_state = "hide";
            swaybar_command = "${pkgs.waybar}/bin/waybar";
            workspace_buttons = "yes";
            strip_workspace_number = "no";
            colors = {
              background = "#3c3836";
              statusline = "#ffffff";
              separator = "#666666";
              focused_workspace = "#4c7899 #285577 #ffffff";
              active_workspace = "#333333 #5f676a #ffffff";
              inactive_workspace = "#333333 #222222 #888888";
              urgent_workspace = "#2f343a #900000 #ffffff";
              binding_mode = "#2f343a #900000 #ffffff";
            };
          }
        ];
        # default_border = "pixel 2";
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Devices (use `hyprctl devices`)
        "$monitor1" = "AOC Q27G2G3R3B 137P4HA000540";
        "$monitor2" = "AOC Q27B3MA 17ZPAHA006135";
        "$keyboard" = "keychron-keychron-k3-pro";
        "$mouse" = "keychron--keychron-link-";

        # Main programs
        "$terminal" = "${lib.getExe hmConfig.programs.wezterm.package}";
        "$menu" = "${lib.getExe hmConfig.programs.rofi.package} -show drun";
        "$fileManager" = "$terminal -e ${lib.getExe hmConfig.programs.yazi.package}";

        monitor = [
          "desc:$monitor1, 2560x1440@165.0, 2560x0, auto"
          "desc:$monitor2, 2560x1440@74.97, 0x0, auto"
        ];

        exec-once = [
          # "nm-applet --indicator &"
          # "blueman-applet &"
          "wl-gammarelay-rs run &"
          "systemctl --user start hypridle"
          "wl-paste --type text --watch cliphist store" #Stores only text data
          "wl-paste --type image --watch cliphist store" #Stores only image data
          # "swww-daemon & swww img ~/Pictures/wallpapers/current" # wallpaper symlinked
        ];

        env = [
          # "XCURSOR_SIZE,14"
          "HYPRCURSOR_THEME,rose-pine-hyprcursor"
          "HYPRCURSOR_SIZE,14"
          "WLR_DRM_NO_ATOMIC,1"
          "HYPRSHOT_DIR,${hmConfig.xdg.userDirs.pictures}/screenshots"
        ];

        general = {
          gaps_in = 2;
          gaps_out = 0;

          border_size = 1;

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          "col.active_border" = "rgba(fabd2fbb) rgba(d79921bb) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = true;

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = true;

          layout = "dwindle";
        };
        decoration = {
          rounding = 2;

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0;
          inactive_opacity = 0.95;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

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

          follow_mouse = 0;

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
          "float,class:^(org.wezfurlong.wezterm)$"
          "tile,class:^(org.wezfurlong.wezterm)$"
        ];
        bind = [
          "SUPER, Q, exec, $terminal"
          "SUPER, N, exec, $fileManager"
          "SUPER, R, exec, nu -c 'use ~/.config/nushell/modules/mod.nu *; nurofi apps'"
          "SUPER, P, exec, nu -c 'use ~/.config/nushell/modules/mod.nu *; nurofi powermenu'"
          # "SUPER, X, exec, ags -t clock"
          # "SUPER, X, exec, ags -t control"
          # "SUPER, X, exec, ags -t systray"
          # "SUPER, X, exec, ags -t workspaces"
          # "SUPER, X, exec, ags -t window-title"

          "SUPER, L, exec, hyprlock --immediate"

          # Windows
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

          "SUPER SHIFT, left, movewindow, l"
          "SUPER SHIFT, right, movewindow, r"
          "SUPER SHIFT, up, movewindow, u"
          "SUPER SHIFT, down, movewindow, d"

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

          "SUPER, t, togglegroup"

          # special workspace (scratchpad)
          "SUPER, S, togglespecialworkspace, magic"
          "SUPER SHIFT, S, movetoworkspace, special:magic"

          "SUPER, SPACE, exec, hyprctl switchxkblayout keychron-keychron-k3-pro next"
          ", PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot --freeze --mode region"
          "CTRL, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot --freeze --mode output"
          "CTRL SHIFT, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot --freeze --mode region --raw | ${pkgs.satty}/bin/satty --filename - --initial-tool brush --copy-command ${pkgs.wl-clipboard}/bin/wl-copy"
          "SUPER, H, exec, ${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"
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
          ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
          ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
          ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
          # ", XF86MonBrightnessDown, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -500"
          # ", XF86MonBrightnessUp, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +500"
          ", XF86MonBrightnessDown, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.1"
          ", XF86MonBrightnessUp, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d +0.1"
        ];
      };
    };

    # Theme
    catppuccin = {
      # global, for all enabled programs
      enable = false;
      flavor = "macchiato";
      accent = "green";
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
        settings = {
          default-key = "B0B3 DFDB B842 BE9C 7468  B511 86F1 EA98 B48F FB19";
        };
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

      rofi = {
        enable = false;
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
        pinentryPackage = pkgs.pinentry-qt;
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
      GNUPGHOME = hmConfig.programs.gpg.homedir;
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
    DOCKER_HOST = "unix:///run/user/${toString config.users.users.l-nafaryus.uid}/podman/podman.sock";
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
    enable = false;
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
      NFQWS_OPT_DESYNC="--dpi-desync=fake --dpi-desync-ttl=3"
      NFQWS_OPT_DESYNC_HTTP="--dpi-desync=fake --dpi-desync-ttl=3"
      NFQWS_OPT_DESYNC_HTTPS="--dpi-desync=fake --dpi-desync-ttl=3"
      NFQWS_OPT_DESYNC_QUIC="--dpi-desync=fake --dpi-desync-ttl=5"
      INIT_APPLY_FW=1
    '';
    filterAddressesSource = "https://antifilter.network/download/ipsmart.lst";
  };

  # gnome virtual fs (used by firefox and etc)
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

  fonts.packages = with pkgs; [nerd-fonts.jetbrains-mono liberation_ttf nerd-fonts.departure-mono];

  programs.steam.enable = true;
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  programs.ssh = {
    enableAskPassword = true;
    askPassword = "${lib.getExe' pkgs.kdePackages.ksshaskpass "ksshaskpass"}";
    hostKeyAlgorithms = ["ssh-ed25519" "ssh-rsa"];
    startAgent = true;
  };

  programs.adb.enable = true;

  services.udev.packages = [pkgs.android-udev-rules];

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  systemd.user.services.wl-gammarelay-rs = {
    enable = true;
    after = ["graphical.target"];
    wantedBy = ["default.target"];
    description = "Gammarelay";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs run'';
    };
    unitConfig.ConditionUser = "l-nafaryus";
  };

  services.garage = {
    enable = true;
    package = pkgs.garage;
    settings = {
      data_dir = "/var/lib/garage/data";
      # metadata_dir = "/var/lib/garaga/meta";
      db_engine = "sqlite";
      replication_factor = 1;
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";
      rpc_secret = "e35682d22035c24473114c5e44bfa8b582589b7517b12b3aa8889cd073412baa";
      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage.localhost";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage.localhost";
        index = "index.html";
      };
      admin = {
        api_bind_addr = "[::]:3903";
        admin_token = "1ec1db228fba7dd0dd8c1a24bbb876f3a3d9bfb4063c0a7706afbf22061f19cf";
        metrics_token = "f5a939b9dff86a6206da337ae2c2b322b2fad7a7ecb0d4d49c08dfa3a9c3f398";
      };
    };
  };
}
