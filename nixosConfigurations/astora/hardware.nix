{
  config,
  lib,
  pkgs,
  ...
}: {
  # Boot
  boot = {
    kernelModules = ["kvm-amd"];
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  };

  users.users.root.initialPassword = "nixos";

  # Filesystem
  fileSystems = lib.mkDefault {
    "/" = {
      device = "/dev/disk/by-label/abysswalker";
      fsType = "btrfs";
      options = ["subvol=root" "compress=zstd"];
    };

    "/boot" = {
      device = "/dev/disk/by-label/ohmyboot";
      fsType = "vfat";
    };

    "/nix" = {
      device = "/dev/disk/by-label/abysswalker";
      fsType = "btrfs";
      options = ["subvol=nix" "compress=zstd" "noatime"];
    };

    "/home" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = ["subvol=home" "compress=zstd"];
    };

    "/swap" = {
      device = "/dev/disk/by-label/abysswalker";
      fsType = "btrfs";
      options = ["subvol=swap" "noatime"];
    };
    "/media/steam-library" = {
      device = "/dev/disk/by-label/siegward";
      fsType = "btrfs";
      options = ["subvol=steam-library" "compress=zstd"];
    };

    "/media/lutris" = {
      device = "/dev/disk/by-label/siegward";
      fsType = "btrfs";
      options = ["subvol=lutris" "compress=zstd"];
    };
  };

  swapDevices = [
    {device = "/swap/swapfile";}
  ];

  services.fstrim.enable = true;

  # Hardware etc
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    nvidia.nvidiaSettings = true;
    nvidia.modesetting.enable = true;
    nvidia.open = false;

    graphics.enable = true;
    graphics.enable32Bit = true;

    bluetooth.enable = true;
  };

  services.pulseaudio.enable = false;

  networking = {
    networkmanager = {
      enable = true;
      enableStrongSwan = true;
      plugins = with pkgs; [networkmanager-l2tp];
    };
    hostName = "astora";
  };
}
