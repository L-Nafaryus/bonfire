{ inputs, config, lib, pkgs, ... }:
with lib;
with lib.custom;
{
    imports = [
        inputs.home-manager.nixosModules.home-manager
    ] ++ (mapModulesRec' (toString ./modules) import);

    # Common config for all nixos machines
    environment.variables = {
        DOTFILES = config.dotfiles.dir;
        DOTFILES_BIN = config.dotfiles.binDir;
    };

    # Configure nix and nixpkgs
    environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
    nix =
    let
        filteredInputs = filterAttrs (n: _: n != "self") inputs;
        nixPathInputs  = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
        registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
    in {
        package = pkgs.nixFlakes;
        extraOptions = "experimental-features = nix-command flakes";
        nixPath = nixPathInputs ++ [
            "nixpkgs-overlays=${config.dotfiles.dir}/overlays"
            "dotfiles=${config.dotfiles.dir}"
        ];
        registry = registryInputs // { dotfiles.flake = inputs.self; };
        settings = {
            substituters = [
                "https://nix-community.cachix.org"
            ];
            trusted-public-keys = [
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
            auto-optimise-store = true;
        };
        gc = {
            automatic = mkDefault true;
            dates = mkDefault "weekly";
            options = mkDefault "--delete-older-than 14d";
        };
    };

    system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
    system.stateVersion = "21.05";

    ## Some reasonable, global defaults
    # This is here to appease 'nix flake check' for generic hosts with no
    # hardware-configuration.nix or fileSystem config.
    fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

    # The global useDHCP flag is deprecated, therefore explicitly set to false
    # here. Per-interface useDHCP will be mandatory in the future, so we enforce
    # this default behavior here.
    networking.useDHCP = mkDefault false;

    # Use the latest kernel
    boot = {
        kernelPackages = mkDefault pkgs.linuxPackages_latest;
        loader = {
            efi.canTouchEfiVariables = mkDefault true;
            systemd-boot.configurationLimit = 10;
            systemd-boot.enable = mkDefault true;
        };
    };

    environment.systemPackages = with pkgs; [
        bind
        cached-nix-shell
        coreutils
        git
        vim
        wget
        curl
        gnumake
        unzip
    ];
}
