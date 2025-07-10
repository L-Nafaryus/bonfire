{
  pkgs,
  lib,
  config,
  bonLib,
  inputs,
  ...
}: {
  system.stateVersion = "23.11";

  imports = [
    bonLib.preconfiguredModules.nixos.common
    ./hardware.nix
    ./users.nix
  ];

  # Nix settings
  nix.settings = {
    trusted-users = ["l-nafaryus"];
    allowed-users = ["l-nafaryus"];
  };

  # Nix packages
  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
    config.cudaSupport = false;

    overlays = [
      (final: prev: {
        blender = prev.blender.override {cudaSupport = true;};
      })
    ];
  };

  # Services
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us,ru";
      variant = "";
      xkbOptions = "grp:win_space_toggle";
    };

    videoDrivers = ["nvidia"];

    wacom.enable = true;
  };

  services.desktopManager.plasma6.enable = false;

  services.displayManager.sddm = {
    enable = false;
    wayland.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --user-menu --cmd sway
      '';
    };
  };

  environment.etc."greetd/environments".text = ''
    sway
    hyprland
  '';

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.sway = {
    enable = true;
  };

  services.dbus = {
    enable = true;
    packages = with pkgs; [networkmanager];
  };

  services.printing = {
    enable = true;
    drivers = [pkgs.hplip];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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

  services.udev = {
    extraRules = ''
      KERNEL=="rtc0", GROUP="audio"
      KERNEL=="hpet", GROUP="audio"
    '';
  };

  services.cockpit.enable = true;

  #services.blueman.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };

  programs.ssh.extraConfig = ''
    Host astora
        HostName 192.168.156.101
        Port 22
        User l-nafaryus

    Host catarina
        HostName 192.168.156.102
        Port 22
        User l-nafaryus

    Host vinheim
        HostName 127.0.0.1
        Port 43022
        User l-nafaryus
        ProxyJump l-nafaryus@catarina
  '';

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [virtiofsd];
    };
  };

  services.k3s = {
    enable = true;
    role = "server";
  };

  networking.firewall = {
    allowedTCPPorts = [6443];
    allowedUDPPorts = [8472];
  };

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
  ];
}
