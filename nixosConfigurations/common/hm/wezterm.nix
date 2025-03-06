{
  pkgs,
  lib,
  config,
  hmConfig,
  inputs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.x86_64-linux.default;
    extraConfig = ''
      return {
          default_prog = { "nu" },
          font_size = 10.0,
          enable_tab_bar = true,
          hide_tab_bar_if_only_one_tab = true,
          term = "wezterm",
          window_padding = {
              left = 0,
              right = 0,
              top = 0,
              bottom = 0
          },
          enable_wayland = false,
          color_scheme = "gruvbox-dark",
          color_schemes = {
            ["gruvbox-dark"] = {
                foreground = "#D4BE98",
                background = "#282828",
                cursor_bg = "#D4BE98",
                cursor_border = "#D4BE98",
                cursor_fg = "#282828",
                selection_bg = "#D4BE98",
                selection_fg = "#45403d",

                ansi = { "#282828", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" },
                brights = { "#eddeb5", "#ea6962", "#a9b665", "#d8a657", "#7daea3", "#d3869b", "#89b482", "#d4be98" }
              }
          },
          keys = {
            { key = 'F11', action = wezterm.action.ToggleFullScreen }
          }
      }
    '';
  };
}
