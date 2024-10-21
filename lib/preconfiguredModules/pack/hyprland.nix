{
  inputs,
  hmConfig,
  username,
  bonLib,
  ...
}: {
  imports = [
    ../nixos/hyprland.nix
    ../nixos/hyprland-greetd.nix
  ];

  home-manager.users.${username} = {...}: {
    imports = [
      (bonLib.injectArgs {inherit hmConfig;})
      inputs.ags.homeManagerModules.default
      ../homeManager/hyprland.nix
    ];
  };
}
