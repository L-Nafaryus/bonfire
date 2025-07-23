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
      inputs.catppuccin.homeManagerModules.catppuccin
      inputs.ags.homeManagerModules.default

      ../common/hm/helix.nix
      ../common/hm/nushell.nix
      # ../common/hm/wezterm.nix
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

      # kdePackages.kmail
      # kdePackages.kmail-account-wizard
      # kdePackages.krdc

      lazydocker
      docker-compose
      podman-compose
      dive

      # kdePackages.ksshaskpass

      dbeaver-bin

      bluez

      wl-clipboard
      cliphist

      ripgrep
      repgrep
      serpl
      delta
      rainfrog

      networkmanagerapplet

      rofi-wayland

      rclone
      bluetui
      musikcube

      chromium
      playerctl
      vscodium
      ghostty
    ];

    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };

    xdg.portal = {
      enable = true;
      configPackages = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        kdePackages.xdg-desktop-portal-kde
      ];
    };

    services.dunst.enable = true;

    # home.pointerCursor = {
    #   name = "Banana";
    #   size = 32;
    #   package = pkgs.banana-cursor;
    #   x11.enable = false;
    #   gtk.enable = true;
    # };

    # gtk = {
    #   enable = true;
    #   cursorTheme = {
    #     name = "Banana";
    #     size = 32;
    #     package = pkgs.banana-cursor;
    #   };
    # };

    wayland.windowManager.sway = {enable = true;};

    #   "wl-gammarelay-rs run &"
    #   "systemctl --user start hypridle"
    #   "wl-paste --type text --watch cliphist store" #Stores only text data
    #   "wl-paste --type image --watch cliphist store" #Stores only image data
    # ];

    #   "SUPER, SPACE, exec, hyprctl switchxkblayout keychron-keychron-k3-pro next"
    #   ", PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot --freeze --mode region"
    #   "CTRL, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot --freeze --mode output"
    #   "SUPER, H, exec, ${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"
    # ];

    # bindel = [
    #   ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
    #   ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    # ];
    # bindl = [
    #   ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    #   ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
    #   ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
    #   ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
    #   ", XF86MonBrightnessDown, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -500"
    #   ", XF86MonBrightnessUp, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +500"
    #   "SUPER, XF86MonBrightnessDown, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay Brightness d -0.1"
    #   "SUPER, XF86MonBrightnessUp, exec, busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay Brightness d +0.1"
    # ];

    # Theme
    catppuccin = {
      # global, for all enabled programs
      enable = false;
      flavor = "macchiato";
      accent = "green";
    };

    programs.bash.enable = true;

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

  fonts.packages = with pkgs; [nerd-fonts.jetbrains-mono liberation_ttf nerd-fonts.departure-mono];

  services.ollama = {
    enable = true;
    acceleration = false;
  };
}
