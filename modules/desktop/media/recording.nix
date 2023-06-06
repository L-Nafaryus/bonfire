{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.desktop.media.recording;
in {
    options.modules.desktop.media.recording = {
        enable = mkBoolOpt false;
        audio.enable = mkBoolOpt true;
        video.enable = mkBoolOpt true;
    };

    config = mkIf cfg.enable {
        services.pipewire.jack.enable = true;

        user.packages = with pkgs;
          (if cfg.audio.enable then [
              unstable.audacity
          ] else []) ++

          (if cfg.video.enable then [
              unstable.obs-studio
              unstable.handbrake
              ffmpeg
          ] else []);
    };
}
