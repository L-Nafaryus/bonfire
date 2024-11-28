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

  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

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
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  programs.ssh.extraConfig = ''
    Host catarina
        HostName 77.242.105.50
        Port 22
        User l-nafaryus
  '';

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;
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
  ];

  programs = {
    fish.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
