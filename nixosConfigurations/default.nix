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
      inherit inputs bonLib;
      bonPkgs = self.packages.x86_64-linux;
    };
  };

  catarina = lib.nixosSystem {
    system = "x86_64-linux";
    modules = with inputs; [
      elnafo-radio.nixosModules.elnafo-radio
      nixos-mailserver.nixosModules.mailserver
      sops-nix.nixosModules.sops
      oscuro.nixosModules.oscuro
      bonModules.bonfire
      ./catarina
    ];
    specialArgs = {bonPkgs = self.packages.x86_64-linux;};
  };

  vinheim = lib.nixosSystem {
    system = "x86_64-linux";
    modules = with inputs; [
      home-manager.nixosModules.home-manager
      ./vinheim
    ];
    specialArgs = {
      inherit inputs bonLib;
      bonPkgs = self.packages.x86_64-linux;
    };
  };


}
