{ options, config, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.hardware.bluetooth;
in {
    options.modules.hardware.bluetooth = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        hardware.bluetooth.enable = true;
    };
}
