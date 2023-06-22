{ config, options, lib, pkgs, ... }:
with builtins;
with lib;
with lib.custom;
let
    cfg = config.modules.desktop.gnome;
in {
    options.modules.desktop.gnome = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
            #gnomeExtensions.containers
            gnomeExtensions.tray-icons-reloaded
        ];

        services.xserver = {
            enable = true;
            # TODO: unable to login with xorg, only wayland works
            displayManager.gdm.enable = false;
            displayManager.gdm.wayland = false;
            displayManager.lightdm.enable = true;

            desktopManager.gnome.enable = true;
        };

    };
}
