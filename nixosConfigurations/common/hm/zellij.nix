{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  programs.zellij = {
    enable = true;
    settings = {
      theme = "gruvbox-dark";
      default_mode = "normal";
      copy_command = "${lib.getExe' pkgs.wl-clipboard "wl-copy"}";
      copy_clipboard = "primary";
    };
  };
}
