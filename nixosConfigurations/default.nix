{
  lib,
  inputs,
  bonModules,
  bonLib,
  self,
  ...
}: {
  astora = lib.nixosSystem {
    system = "x86_64-linux";
    modules = with inputs; [
      home-manager.nixosModules.home-manager
      bonModules.bonfire
      ./astora
    ];
    specialArgs = {
      inherit inputs;
      bonPkgs = self.packages.x86_64-linux;
    };
  };

  catarina = lib.nixosSystem {
    system = "x86_64-linux";
    modules = with inputs; [
      nixos-mailserver.nixosModules.mailserver
      sops-nix.nixosModules.sops
      oscuro.nixosModules.oscuro
      bonModules.bonfire
      ./catarina
    ];
    specialArgs = {bonPkgs = self.packages.x86_64-linux;};
  };
}
