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
    extraGroups = ["networkmanager" "wheel" "audio" "libvirtd" "input" "video" "disk" "wireshark" "podman"];
    group = "users";
    uid = 1000;
    initialPassword = "nixos";
    shell = pkgs.nushell;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1YGp8AI48hJUSQBZpuKLpbj2+3Q09vq64NxFr0N1MS"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHA3b8JfFtr3yfeWWOcmF0qSuxNocSGnZiXeJhUE4n4P"
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
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

      ../common/hm/helix.nix
      ../common/hm/nushell.nix
    ];

    home.packages = with pkgs; [
      taskwarrior3

      gparted

      firefox
      thunderbird

      qpwgraph

      lutris
      wine
      winetricks
      gamemode

      inkscape
      imagemagick
      yt-dlp
      ffmpeg

      qbittorrent
      telegram-desktop

      onlyoffice-bin

      # btop
      lua
      # bat
      tree
      bonPkgs.bonvim

      kdePackages.kmail
      kdePackages.kmail-account-wizard
      kdePackages.krdc

      lazydocker
      docker-compose
      podman-compose
      dive

      kdePackages.ksshaskpass

      dbeaver-bin

      bluez

      wl-clipboard
      cliphist

      ripgrep
      repgrep
      serpl
      delta

      networkmanagerapplet
    ];

    xdg.portal = {
      enable = true;
      configPackages = with pkgs; [
        xdg-desktop-portal-hyprland
        kdePackages.xdg-desktop-portal-kde
      ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
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

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Devices (use `hyprctl devices`)
        "$monitor1" = "Acer Technologies EK240Y E204018E03W01";
        "$monitor2" = "Acer Technologies EK240Y E204018873W01";
        "$keyboard" = "keychron-keychron-k3-pro";
        "$mouse" = "keychron--keychron-link-";

        # Main programs
        "$terminal" = "${lib.getExe hmConfig.programs.wezterm.package}";
        "$menu" = "${lib.getExe hmConfig.programs.rofi.package} -show drun";
        "$fileManager" = "$terminal -e ${lib.getExe hmConfig.programs.yazi.package}";

        monitor = [
          "desc:$monitor1, 1920x1080@74.99, 0x0, auto"
          "desc:$monitor2, 1920x1080@74.99, 1920x0, auto"
        ];

        exec-once = [
          "nm-applet --indicator &"
          "blueman-applet &"
          "wl-gammarelay-rs run &"
          "systemctl --user start hypridle"
          "wl-paste --type text --watch cliphist store" #Stores only text data
          "wl-paste --type image --watch cliphist store" #Stores only image data
          # "swww-daemon & swww img ~/Pictures/wallpapers/current" # wallpaper symlinked
        ];

        env = [
          "XCURSOR_SIZE,14"
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
          "float,class:^(org.wezfurlong.wezterm)$"
          "tile,class:^(org.wezfurlong.wezterm)$"
        ];
        bind = [
          "SUPER, Q, exec, $terminal"
          "SUPER, N, exec, $fileManager"
          "SUPER, R, exec, $menu"
          "SUPER, X, exec, ags -t clock"
          "SUPER, X, exec, ags -t control"
          "SUPER, X, exec, ags -t systray"
          "SUPER, X, exec, ags -t workspaces"
          "SUPER, X, exec, ags -t window-title"

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
          ", PRINT, exec, hyprshot --freeze --mode region"
          "CTRL, PRINT, exec, hyprshot --freeze --mode output"
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
          ", XF86MonBrightnessDown, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -500"
          ", XF86MonBrightnessUp, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +500"
          "SUPER, XF86MonBrightnessDown, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay Brightness d -0.1"
          "SUPER, XF86MonBrightnessUp, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay Brightness d +0.1"
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

    programs.yazi = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      keymap = {
        input.prepend_keymap = [
          {
            run = "close";
            on = ["<Esc>"];
            desc = "Cancel input";
          }
          {
            run = ''shell "$SHELL" --block'';
            on = "!";
            desc = "Drop in shell";
          }
        ];
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
          color_theme = "gruvbox_material_dark";
        };
      };

      fzf.enable = true;

      lazygit.enable = true;

      wezterm = {
        enable = true;
        package = inputs.wezterm.packages.x86_64-linux.default;
        extraConfig = ''
          return {
              default_prog = { "nu" },
              font_size = 8.0,
              enable_tab_bar = true,
              hide_tab_bar_if_only_one_tab = true,
              term = "wezterm",
              window_padding = {
                  left = 0,
                  right = 0,
                  top = 0,
                  bottom = 0
              },
              enable_wayland = false,
              color_scheme = "gruvbox-dark",
              color_schemes = {
                ["gruvbox-dark"] = {
                    foreground = "#D4BE98",
                    background = "#282828",
                    cursor_bg = "#D4BE98",
                    cursor_border = "#D4BE98",
                    cursor_fg = "#282828",
                    selection_bg = "#D4BE98",
                    selection_fg = "#45403d",

                    ansi = { "#282828", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
                    brights = { "#eddeb5", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" }
                  }
              },
              keys = {
                { key = 'F11', action = wezterm.action.ToggleFullScreen }
              }
          }
        '';
      };

      zellij = {
        enable = true;
        settings = {
          theme = "gruvbox-dark";
          default_mode = "normal";
          copy_command = "${lib.getExe' pkgs.wl-clipboard "wl-copy"}";
          copy_clipboard = "primary";
        };
      };

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

      ssh-agent.enable = true;
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

  fonts.packages = with pkgs; [nerd-fonts.jetbrains-mono liberation_ttf];

  services.ollama = {
    enable = true;
    acceleration = false;
  };
}
