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

      ksshaskpass

      dbeaver-bin

      bluez

      wl-clipboard
      cliphist
    ];

    xdg.portal = {
      enable = true;
      configPackages = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
      ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    # Theme
    catppuccin = {
      # global, for all enabled programs
      enable = false;
      flavor = "macchiato";
      accent = "green";
    };

    programs.helix = {
      enable = true;
      settings = {
        theme = "gruvbox";
        editor.cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      extraPackages = with pkgs; [pyright ruff alejandra];
      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "alejandra";
          }

          {
            name = "python";
            language-id = "python";
            roots = ["pyproject.toml" "setup.py" "poetry.lock" "uv.lock" "pdm.lock"];
            language-servers = ["ruff" "pyright"];
            auto-format = true;
            formatter = {
              command = "ruff";
              args = ["format" "-"];
            };
            file-types = ["py"];
            comment-token = "#";
            shebangs = ["python"];
          }
        ];

        language-server = {
          pyright = {
            command = "pyright-langserver";
            args = ["--stdio"];
            config.python.analysis = {
              venvPath = ".";
              venv = ".venv";
              lint = true;
              inlayHint.enable = true;
              autoSearchPaths = true;
              diagnosticMode = "workspace";
              useLibraryCodeForType = true;
              logLevel = "Error";
              typeCheckingMode = "off";
              autoImoprtCompletion = true;
              reportOptionalSubscript = false;
              reportOptionalMemberAccess = false;
            };
          };
          ruff = {
            command = "ruff";
            args = ["server"];
            environment = {RUFF_TRACE = "messages";};
          };
        };
      };
    };

    programs = {
      nushell = {
        enable = true;
        # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
        #configFile.source = ./.../config.nu;
        # for editing directly to config.nu
        extraConfig = ''
          let carapace_completer = {|spans|
              carapace $spans.0 nushell $spans | from json
          }
          $env.config = {
           show_banner: false,
           completions: {
               case_sensitive: false # case-sensitive completions
               quick: true    # set to false to prevent auto-selecting completions
               partial: true    # set to false to prevent partial filling of the prompt
               algorithm: "fuzzy"
               external: {
                   enable: true
                   max_results: 100
                   completer: $carapace_completer
                 }
               }
          }
        '';
      };

      carapace = {
        enable = true;
        enableNushellIntegration = true;
        enableBashIntegration = true;
      };

      starship = {
        enable = true;
        enableNushellIntegration = true;
        enableBashIntegration = true;
        settings = {
          add_newline = true;
          format = ''
            $all $fill $time
            $character
          '';
          fill = {
            symbol = " ";
          };
          line_break = {
            disabled = true;
          };
          directory = {
            truncate_to_repo = false;
          };
          time = {
            disabled = false;
            use_12hr = true;
          };
          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[❯](bold red)";
          };
          nix_shell = {
            symbol = " ";
            heuristic = true;
          };
        };
      };

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
}
