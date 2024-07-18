{
  pkgs,
  nixvimPkgs,
  fenixPkgs,
  bonLib,
  lib,
  ...
}: let
  drv = nixvimPkgs.makeNixvimWithModule {
    pkgs = pkgs;
    module = bonLib.preconfiguredModules.bonvim;
    extraSpecialArgs = {
      rustc = fenixPkgs.complete.rustc;
      cargo = fenixPkgs.complete.cargo;
      rust-analyzer = fenixPkgs.complete.rust-analyzer;
    };
  };
in
  drv
  // {
    pname = "bonvim";
    version = "unknown";
    meta = with lib;
      drv.meta
      // {
        description = "NixVim distribution for NeoVim with a customized collection of plugins inspired by the LazyVim distribution.";
        license = licenses.mit;
        maintainers = with bonLib.maintainers; [L-Nafaryus];
        platforms = platforms.linux;
      };
  }
