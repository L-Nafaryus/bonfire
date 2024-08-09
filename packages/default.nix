# self.packages.${system}
#
{
  lib,
  bonLib,
  self,
  inputs,
  ...
}: let
  platformInputs = system: rec {
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    lib = pkgs.lib;

    inherit bonLib;
    bonModules = self.nixosModules;
    bonPkgs = self.packages.${system};

    craneLib = inputs.crane.mkLib pkgs;
    fenixPkgs = inputs.fenix.packages.${system};
    nixvimPkgs = inputs.nixvim.legacyPackages.${system};
    weztermPkgs = inputs.wezterm.packages.${system};
  };
in
  bonLib.collectPackages platformInputs {
    bonfire-docs = {
      source = ./bonfire-docs;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
      extraArgs = {inherit self;};
    };

    netgen = {
      source = ./netgen;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    dearpygui = {
      source = ./dearpygui;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    openfoam = {
      source = ./openfoam;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    spoofdpi = {
      source = ./spoofdpi;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    ultimmc = {
      source = ./ultimmc;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.libsForQt5.callPackage;
    };

    cargo-shuttle = {
      source = ./cargo-shuttle;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    bonvim = {
      source = ./bonvim;
      platforms = ["x86_64-linux"];
      builder = {...}: import;
    };

    zapret = {
      source = ./zapret;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    # Pass for cache

    blender = {
      source = ./blender;
      platforms = ["x86_64-linux"];
      builder = {...}: import;
    };

    wezterm = {
      source = ./wezterm;
      platforms = ["x86_64-linux"];
      builder = {...}: import;
    };

    # Container images

    nix-minimal = {
      source = ./nix-minimal;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    nix-runner = {
      source = ./nix-runner;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    postgresql = {
      source = ./postgresql;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };

    redis = {
      source = ./redis;
      platforms = ["x86_64-linux"];
      builder = {pkgs, ...}: pkgs.callPackage;
    };
  }
