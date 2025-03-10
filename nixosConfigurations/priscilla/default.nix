{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  system.stateVersion = "25.05";

  system.build.qcow2 = import "${modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = 10240;
    format = "qcow2";
    partitionTableType = "hybrid";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot = {
    loader.grub.enable = lib.mkForce true;
    loader.grub.device = lib.mkDefault "/dev/vda";
    loader.timeout = lib.mkForce 0;
    kernelParams = ["console=tty1" "console=ttyS0,115200"];
  };

  networking = {
    useDHCP = true;
    firewall.enable = true;
  };

  services = {
    qemuGuest = {
      enable = true;
    };

    openssh = {
      enable = true;
      openFirewall = true;
    };

    journald.extraConfig = ''
      SystemMaxUse=100M
      MaxFileSec=7day
    '';

    resolved = {
      enable = true;
      dnssec = "false";
    };
  };

  users.users.l-nafaryus = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.nushell;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1YGp8AI48hJUSQBZpuKLpbj2+3Q09vq64NxFr0N1MS"
    ];
    initialPassword = "nixos";
  };

  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.l-nafaryus.openssh.authorizedKeys.keys;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["l-nafaryus"];
      allowed-users = ["l-nafaryus"];
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
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "git+https://vcs.elnafo.ru/"
        "git+ssh://vcs.elnafo.ru/"
      ];
    };
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
