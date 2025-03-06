{
  config,
  pkgs,
  lib,
  bonPkgs,
  bonLib,
  inputs,
  ...
}: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hmbackup";

  # Users
  users.users.root.hashedPasswordFile = config.sops.secrets."users/root".path;

  users.users.l-nafaryus = {
    isNormalUser = true;
    createHome = true;
    description = "L-Nafaryus";
    extraGroups = ["networkmanager" "wheel"];
    group = "users";
    shell = pkgs.nushell;
    hashedPasswordFile = config.sops.secrets."users/l-nafaryus".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1YGp8AI48hJUSQBZpuKLpbj2+3Q09vq64NxFr0N1MS nafaryus"
    ];
  };

  home-manager.users.l-nafaryus = {pkgs, ...}: let
    hmConfig = config.home-manager.users.l-nafaryus;
  in {
    home.stateVersion = "23.11";
    home.username = "l-nafaryus";
    home.homeDirectory = "/home/l-nafaryus";
    imports = [
      (bonLib.injectArgs {
        inherit hmConfig;
        inherit inputs;
      })
      ../common/hm/helix.nix
      ../common/hm/nushell.nix
      ../common/hm/zellij.nix
      ../common/hm/yazi.nix
    ];

    home.packages = with pkgs; [
      ripgrep
      repgrep
    ];
  };

  users.users.nginx.extraGroups = ["acme" "papermc"];

  users.users.kirill = {
    isNormalUser = true;
    createHome = true;
    description = "Kirill";
    extraGroups = ["networkmanager"];
    group = "users";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuxRavm+add0e0ODmp1ZQ1h3qV/7Yi8/h+nRIykV7+RKiBwvNK9kOz+vjS0jEUwmW7CqvbjI/QexUkK3UdANSeuXk4HU3CSdPM//yIcoydpEVDkfNL80ZClHISjAg0HHnD2WZ5UzOFdm0av7/93zkh+BP9kabEQWV6qMfFqTQkd2vvOMJRUEz4jiAuXBb9wTMYmAhv0WDlNVPdkSJlTHjE1eSxHqEBnPDtX7I9BqxLRmEs7JTqR2P1FBUP3ILhOx7/g0gkIPZDc/5ce44+cyMVLTkV2lP08rh1J73JMyMUnyWy5FRC+znLOyrYvgsbuKteK21yYBrN6AQYrDoLKcKw084mz2a38CA0GnGHVbXzyDEB6HoC9eQt+FGUrrC6Z9V3aUrGIRUbPNXTjmks6BJH0X44sWj/oKoimkbi191ADEoV1lCmGSH+XfigjR+Dc8fWWm2ekmbfGMVEqbFPNJF+rgJbhOSLtpXmMacs7+4z2vKJYRUe3oHjPFLePk0XfJE= kirill"
    ];
  };
}
