{
  pkgs,
  nixvim-pkgs,
  bonconfigs,
  fenix-pkgs,
  ...
}:
nixvim-pkgs.makeNixvimWithModule {
  pkgs = pkgs;
  module = import bonconfigs.bonvim;
  extraSpecialArgs = {
    rustc = fenix-pkgs.complete.rustc;
    cargo = fenix-pkgs.complete.cargo;
    rust-analyzer = fenix-pkgs.complete.rust-analyzer;
  };
}
