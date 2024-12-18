{
  config,
  lib,
  pkgs,
  rustc ? pkgs.rustc,
  cargo ? pkgs.cargo,
  rust-analyzer ? pkgs.rust-analyzer,
  ...
}: {
  # General
  globals.mapleader = " ";

  opts = {
    # Show line numbers
    number = true;
    relativenumber = true;
    # Tab need 4 spaces please
    expandtab = true;
    tabstop = 4;
    softtabstop = 4;
    shiftwidth = 4;
    showtabline = 4;
    # Hide * markup
    conceallevel = 2;
    # Confirm on save
    confirm = true;

    cursorline = true;
    # Invisible characters I see you
    list = true;

    ignorecase = true;

    grepprg = "${lib.getExe pkgs.ripgrep} --vimgrep";

    termguicolors = true;
    # Splits
    splitbelow = true;
    splitright = true;
    splitkeep = "screen";
    # U, u, undo
    undofile = true;
    undolevels = 10000;
    updatetime = 200;
    # Command line completion mode
    wildmode = "longest:full,full";

    smoothscroll = true;

    autowrite = true;

    pumblend = 10;
    pumheight = 10;
  };

  globals = {
    bigfile_size = 1024 * 1024 * 1.5;
  };

  editorconfig.enable = true;

  # Clipboard
  clipboard = {
    register = "unnamedplus";
    providers.wl-copy.enable = true;
  };

  # Copy/paste
  plugins.yanky = {
    enable = true;
    settings.system_clipboard.sync_with_ring = true;
  };

  plugins.web-devicons.enable = true;

  diagnostics = {
    underline = true;
    update_in_insert = false;
    # lsp diagnostics grouped in the end of file
    virtual_text = {
      spacing = 4;
      source = "if_many";
      prefix = "●";
    };
    # lsp diagnostic lines disabled by default, toggle it for pretty lines
    virtual_lines = false;
    # sort diagnostic messages
    severity_sort = true;
    # hightlight word under cursor
    document_highlight = {
      enabled = true;
    };
  };

  # Theme
  colorschemes = {
    gruvbox.enable = true;
    catppuccin = {
      enable = false;
      settings = {
        flavour = "macchiato";
        no_bold = false;
        no_italic = false;
        no_underline = false;
        integrations = {
          cmp = true;
          notify = true;
          gitsigns = true;
          neotree = true;
          which_key = true;
          illuminate = {
            enabled = true;
          };
          treesitter = true;
          telescope.enabled = true;
          indent_blankline.enabled = true;
          mini.enabled = true;
          native_lsp = {
            enabled = true;
            inlay_hints = {
              background = true;
            };
            underlines = {
              errors = ["undercurl"];
              hints = ["undercurl"];
              information = ["undercurl"];
              warnings = ["undercurl"];
            };
          };
        };
      };
    };
  };

  # File tree
  plugins.neo-tree = {
    enable = true;
    filesystem = {
      useLibuvFileWatcher = true;
      filteredItems = {
        hideDotfiles = false;
        hideGitignored = false;
      };
    };
    defaultComponentConfigs = {
      indent = {
        withExpanders = true;
        expanderCollapsed = "";
        expanderExpanded = "";
        expanderHighlight = "NeoTreeExpander";
      };
    };
  };

  # UI
  plugins.noice = {
    enable = true;
    settings = {
      lsp.override = {
        "cmp.entry.get_documentation" = true;
        "vim.lsp.util.convert_input_to_markdown_lines" = true;
        "vim.lsp.util.stylize_markdown" = true;
      };
      presets = {
        long_message_to_split = true;
      };
    };
  };

  plugins.dressing = {
    enable = true;
  };

  # Status line
  plugins.bufferline = {
    enable = true;
    settings.options = {
      diagnostics = "nvim_lsp";
      mode = "buffers";

      offsets = [
        {
          filetype = "neo-tree";
          text = "Neo-tree";
          highlight = "Directory";
          text_align = "left";
        }
      ];
    };
  };

  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        globalstatus = true;
        extensions = ["neo-tree"];
      };
      sections = {
        lualine_a = [
          "mode"
          {
            separator.right = "";
          }
        ];
        lualine_b = [
          "branch"
          {
            icon = "";
            separator.right = "";
          }
        ];
        lualine_c = [
          "diagnostics"
          {
            separator.right = ">";
            sources = ["nvim_lsp"];
            symbols = {
              error = " ";
              warn = " ";
              info = " ";
              hint = "󰝶 ";
            };
          }

          "filetype"
          {
            icon_only = true;
            separator = "";
            padding = {
              left = 1;
              right = 0;
            };
          }
          "filename"
          {
            path = 1;
          }
        ];
        lualine_x = [
          "diff"
        ];
        lualine_y = [
          "progress"
          {
            separator.left = "";
          }
          "location"
          {
            separator.right = "";
          }
        ];
        lualine_z = [
          {
            separator.left = "";
            icon = " ";
            __unkeyed-1.__raw = ''
              function(text)
                  return os.date("%R")
              end
            '';
          }
        ];
      };
    };
  };

  plugins.notify.enable = true;

  plugins.project-nvim = {
    enable = true;
    enableTelescope = true;
    settings.show_hidden = true;
  };

  # Syntax highlight
  plugins.treesitter = {
    enable = true;
  };

  plugins.treesitter-textobjects.enable = true;

  # Double trouble of your code
  plugins.trouble = {
    enable = true;
  };

  # Multifile search/replace
  plugins.spectre = {
    enable = true;
    findPackage = pkgs.ripgrep;
    replacePackage = pkgs.gnused;
  };

  plugins.which-key = {
    enable = true;
    settings = {
      icons.group = "+";
      spec = [
        {
          __unkeyed = "<leader>g";
          group = "Git";
        }
        {
          __unkeyed = "<leader>c";
          group = "Code";
        }
        {
          __unkeyed = "<leader>s";
          group = "Search";
        }
        {
          __unkeyed = "<leader>w";
          group = "Window";
        }
        {
          __unkeyed = "<leader>q";
          group = "Quit";
        }
      ];
    };
  };

  # LSP
  plugins = {
    lsp-lines.enable = true;
    lsp-format.enable = true;
    lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        # vim.diagnostic.<action>
        diagnostic = {
          "<leader>cd" = {
            action = "open_float";
            desc = "Line diagnostics";
          };
        };
        # vim.lsp.buf.<action>
        lspBuf = {
          "K" = "hover";
          "gK" = "signature_help";
          "gr" = "references";
          "gd" = "definition";
          "gi" = "implementation";
          "gt" = "type_definition";
          "cr" = "rename";
          "cf" = "format";
        };
        extra = [
          {
            key = "<leader>cf";
            action.__raw = "vim.lsp.buf.format";
            options.desc = "Format";
          }
        ];
      };
      servers = {
        clangd = {
          enable = true;
          cmd = [
            "${config.plugins.lsp.servers.clangd.package}/bin/clangd"
            "--background-index"
            "--clang-tidy"
            "--header-insertion=iwyu"
            "--completion-style=detailed"
            "--function-arg-placeholders"
            "--fallback-style=llvm"
          ];
        };
        cmake.enable = true;
        nil_ls.enable = true;
        pyright.enable = true;
        ruff.enable = true;
        # pylyzer.enable = true;    # not working with virtual environments currently :(
        #pylsp = {
        #  enable = true; # https://github.com/nix-community/nixvim/pull/1893
        #  settings.plugins = {
        #    pyflakes.enabled = true;
        #    black.enabled = true;
        #  };
        #};
        rust_analyzer = {
          enable = true;
          package = rust-analyzer;
          cargoPackage = cargo;
          rustcPackage = rustc;
          installCargo = false;
          installRustc = false;
          settings = {
            checkOnSave = true;
            check.command = "clippy";
            inlayHints = {
              enable = true;
              showParameterNames = true;
            };
            procMacro.enable = true;
          };
        };
        volar.enable = true;
        tailwindcss.enable = true;
        marksman.enable = true;
      };
    };
  };

  # VCS
  plugins.gitsigns = {
    enable = true;
    settings = {
      signs = {
        add = {
          text = "▎";
        };
        change = {
          text = "▎";
        };
        delete = {
          text = "";
        };
        untracked = {
          text = "▎";
        };
        topdelete = {
          text = "";
        };
        changedelete = {
          text = "▎";
        };
      };
    };
  };

  plugins.lazygit.enable = true;

  # Formatting
  plugins.none-ls = {
    enable = true;
    # nix
    sources.formatting.alejandra.enable = true;
  };

  # Search, search, search
  plugins.telescope = {
    enable = true;
    extensions.fzf-native.enable = true;
    keymaps = {
      "<leader>sgf" = {
        action = "git_files";
        options = {
          desc = "Files";
        };
      };
      "<leader>sgc" = {
        action = "git_commits";
        options = {
          desc = "Commits";
        };
      };
      "<leader>sgs" = {
        action = "git_status";
        options = {
          desc = "Status";
        };
      };
      "<leader>sk" = {
        action = "keymaps";
        options = {
          desc = "Key Maps";
        };
      };
      "<leader>sf" = {
        action = "live_grep";
        options = {
          desc = "Grep Root Directory";
        };
      };
    };
  };

  plugins.todo-comments.enable = true;

  # Terminal
  plugins.toggleterm = {
    enable = true;
    settings = {
      direction = "float";
      open_mapping = "[[<c-/>]]";
    };
  };

  # Completion
  plugins = {
    cmp = {
      enable = true;
      settings = {
        sources = [
          {
            name = "nvim_lsp";
          }
          {
            name = "path";
          }
          {
            name = "buffer";
          }
        ];
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText";
          };
        };
        mapping = {
          "<c-space>" = "cmp.mapping.complete()";
          "<cr>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
          "<tab>" = "cmp.mapping(cmp.mapping.confirm({ select = true }), { 'i', 's', 'c' })";
          "<up>" = "cmp.mapping.select_prev_item()";
          "<down>" = "cmp.mapping.select_next_item()";
        };
        formatting.format = ''
          function(entry, item)
              local icons = {
                Array         = " ",
                Boolean       = "󰨙 ",
                Class         = " ",
                Codeium       = "󰘦 ",
                Color         = " ",
                Control       = " ",
                Collapsed     = " ",
                Constant      = "󰏿 ",
                Constructor   = " ",
                Copilot       = " ",
                Enum          = " ",
                EnumMember    = " ",
                Event         = " ",
                Field         = " ",
                File          = " ",
                Folder        = " ",
                Function      = "󰊕 ",
                Interface     = " ",
                Key           = " ",
                Keyword       = " ",
                Method        = "󰊕 ",
                Module        = " ",
                Namespace     = "󰦮 ",
                Null          = " ",
                Number        = "󰎠 ",
                Object        = " ",
                Operator      = " ",
                Package       = " ",
                Property      = " ",
                Reference     = " ",
                Snippet       = " ",
                String        = " ",
                Struct        = "󰆼 ",
                TabNine       = "󰏚 ",
                Text          = " ",
                TypeParameter = " ",
                Unit          = " ",
                Value         = " ",
                Variable      = "󰀫 ",
              }

              if icons[item.kind] then
                item.kind = icons[item.kind] .. item.kind
              end

              local widths = {
                abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
                menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
              }

              for key, width in pairs(widths) do
                if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                  item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
                end
              end

              return item
            end
        '';
      };
    };
    cmp-nvim-lsp.enable = true;
    cmp-path.enable = true;
    cmp-buffer.enable = true;
  };

  # Keymaps
  keymaps = [
    # General
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>qa<cr>";
      options = {desc = "Quit All";};
    }

    {
      mode = "n";
      key = "<leader>ww";
      action = "<C-W>p";
      options = {desc = "Other Window";};
    }
    {
      mode = "n";
      key = "<leader>wd";
      action = "<C-W>c";
      options = {desc = "Delete Window";};
    }
    {
      mode = "n";
      key = "<leader>ws";
      action = "<C-W>s";
      options = {desc = "Split Below";};
    }
    {
      mode = "n";
      key = "<leader>wv";
      action = "<C-W>v";
      options = {desc = "Split Right";};
    }
    {
      mode = "n";
      key = "<C-Left>";
      action = "<C-W>h";
      options = {desc = "Go To Left Window";};
    }
    {
      mode = "n";
      key = "<C-Down>";
      action = "<C-W>j";
      options = {desc = "Go To Lower Window";};
    }
    {
      mode = "n";
      key = "<C-Up>";
      action = "<C-W>k";
      options = {desc = "Go To Upper Window";};
    }
    {
      mode = "n";
      key = "<C-Right>";
      action = "<C-W>l";
      options = {desc = "Go To Right Window";};
    }

    {
      mode = "v";
      key = ">";
      action = ">gv";
      options = {desc = "Indent right selected text";};
    }
    {
      mode = "v";
      key = "<";
      action = "<gv";
      options = {desc = "Indent left selected text";};
    }

    # Clipboard
    {
      mode = ["n" "x"];
      key = "y";
      action = "<Plug>(YankyYank)";
      options = {desc = "Yank Text";};
    }
    {
      mode = ["n" "x"];
      key = "p";
      action = "<Plug>(YankyPutAfter)";
      options = {desc = "Put Yanked Text After Cursor";};
    }
    {
      mode = ["n" "x"];
      key = "P";
      action = "<Plug>(YankyPutBefore)";
      options = {desc = "Put Yanked Text Before Cursor";};
    }
    {
      mode = ["n" "x"];
      key = "gp";
      action = "<Plug>(YankyGPutAfter)";
      options = {desc = "Put Yanked Text After Selection";};
    }
    {
      mode = ["n" "x"];
      key = "gP";
      action = "<Plug>(YankyGPutBefore)";
      options = {desc = "Put Yanked Text Befor Selection";};
    }

    {
      mode = "n";
      key = "<leader>cl";
      action.__raw = ''require("lsp_lines").toggle'';
      options = {desc = "Toggle LSP lines";};
    }

    # Terminal
    {
      mode = "t";
      key = "<esc><esc>";
      action = "<c-\\><c-n>";
      options = {desc = "Enter Normal Mode";};
    }
    # Etc
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<cr>";
      options = {desc = "Open/Close Neotree";};
    }
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<cr>";
      options = {
        desc = "LazyGit (root dir)";
      };
    }
  ];
}
