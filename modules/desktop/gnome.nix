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
            gnomeExtensions.containers
            gnomeExtensions.tray-icons-reloaded
        ];

        services.xserver = {
            enable = true;
            displayManager.gdm.enable = false;
            displayManager.lightdm.enable = true;
            displayManager.gdm.wayland = false;

            desktopManager.gnome.enable = true;
	    #autorun = false;
	    #displayManager.startx.enable = true;
        };

    };
}
