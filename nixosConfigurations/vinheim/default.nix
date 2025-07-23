{
  pkgs,
  lib,
  config,
  bonLib,
  ...
}: {
  system.stateVersion = "23.11";

  imports = [
    ./hardware.nix
    ./users.nix
  ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://cache.elnafo.ru"
        "https://bonfire.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.elnafo.ru:j3VD+Hn+is2Qk3lPXDSdPwHJQSatizk7V82iJ2RP1yo="
        "bonfire.cachix.org-1:mzAGBy/Crdf8NhKail5ciK7ZrGRbPJJobW6TwFb7WYM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      auto-optimise-store = true;
      trusted-users = ["l-nafaryus"];
      allowed-users = ["l-nafaryus"];
    };
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  # Nix packages
  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
    config.cudaSupport = false;
  };

  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };

  programs.sway = {enable = true;};

  services.dbus = {
    enable = true;
    packages = with pkgs; [networkmanager];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    # settings.PasswordAuthentication = false;
    # settings.KbdInteractiveAuthentication = false;
  };

  services.autossh = {
    sessions = [
      {
        extraArguments = "-N -R 42022:localhost:22 l-nafaryus@catarina-rproxy";
        monitoringPort = 20000;
        name = "elnafo-peer";
        user = "l-nafaryus";
      }
    ];
  };

  services.printing = {
    enable = true;
  };

  programs.ssh.extraConfig = ''
    Host catarina
        HostName elnafo.ru
        Port 22
        User l-nafaryus

    Host catarina-rproxy
        HostName elnafo.ru
        Port 22
        User l-nafaryus
        IdentityFile ~/.ssh/vinheim.id_ed25519
        # IdentitiesOnly yes

    Host astora
        HostName 192.168.156.101
        Port 22
        User l-nafaryus
        ProxyJump l-nafaryus@elnafo.ru
  '';

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [virtiofsd];
    };
  };

  # Base packages
  environment.systemPackages = with pkgs; [
    wget

    parted
    ntfs3g
    sshfs
    exfat
    btrfs-progs
    btrbk

    lm_sensors
    btop

    git
    git-lfs
    lazygit

    nnn
    fzf
    ripgrep
    fd

    unzip

    fishPlugins.fzf-fish
    fishPlugins.tide
    fishPlugins.grc
    fishPlugins.hydro
    grc

    gnupg
    pass

    bat

    kubectl
    kubernetes-helm
    k9s
  ];

  programs = {
    fish.enable = true;

    neovim = {
      enable = true;
      defaultEditor = false;
    };
  };

  services.k3s = {
    enable = true;
    role = "server";
  };

  networking.firewall = {
    allowedTCPPorts = [
      6443
      # distribution (registry)
      5000
    ];
    allowedUDPPorts = [8472];
  };

  services.glpiAgent = {
    enable = true;
    settings = {
      server = "https://glpi.soft72.ru";
    };
  };
}
