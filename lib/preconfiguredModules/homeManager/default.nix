#{
#  lib,
#  inputs,
#  ...
#}:
{
  ags = import ./ags;
  hyprland = import ./hyprland.nix;
  hypridle = import ./hypridle.nix;
  hyprlock = import ./hyprlock.nix;

  #hyprland =
  #  (lib.evalModules {
  #    modules = [
  #      inputs.home-manager.nixosModules.home-manager
  #      ./hyprland
  #    ];
  #  })
  #  .config;
}
