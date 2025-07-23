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

      function tab_title(tab_info)
        local title = tab_info.tab_title

        if title and #title > 0 then
          return title
        end

        return tab_info.active_pane.title
      end

      wezterm.on(
        "format-tab-title",
        function(tab, tabs, panes, config, hover, max_width)
          local background = "#333333"
          local foreground = "#808080"

          if tab.is_active then
            background = "#98971a" -- "#b8bb26"
            foreground = "#333333"
          else
            background = "#ebdbb2"
            foreground = "#333333"
          end

          local title = tab_title(tab)

          title = wezterm.truncate_right(string.format(" %s ", title), max_width - 2)

          return {
            { Background = { Color = background  } },
            { Foreground = { Color = "#333333"} },
            { Text = wezterm.nerdfonts.pl_left_hard_divider },
            { Background = { Color = background } },
            { Foreground = { Color = "#333333" } },
            { Text = title },
            { Background = { Color = "#333333" } },
            { Foreground = { Color = background } },
            { Text = wezterm.nerdfonts.pl_left_hard_divider },
          }
        end
      )

      local config = {
          default_prog = { "nu" },
          font_size = 10.0,
          enable_tab_bar = true,
          hide_tab_bar_if_only_one_tab = true,
          term = "wezterm",
          audible_bell = "Disabled",
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
          },
          use_fancy_tab_bar = false,
          xcursor_theme="Banana"
      }

      return config
    '';
  };
}
