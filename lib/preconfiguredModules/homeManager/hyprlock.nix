{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  programs.hyprlock = {
    enable = true;
  };
}
