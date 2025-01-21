{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  programs.helix = {
    enable = true;
    extraPackages = with pkgs; [wl-clipboard pyright ruff alejandra];

    settings = {
      theme = "gruvbox";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "alejandra";
        }

        {
          name = "python";
          language-id = "python";
          roots = ["pyproject.toml" "setup.py" "poetry.lock" "uv.lock" "pdm.lock"];
          language-servers = ["ruff" "pyright"];
          auto-format = true;
          formatter = {
            command = "ruff";
            args = ["format" "-"];
          };
          file-types = ["py"];
          comment-token = "#";
          shebangs = ["python"];
        }
      ];

      language-server = {
        pyright = {
          command = "pyright-langserver";
          args = ["--stdio"];
          config.python.analysis = {
            venvPath = ".";
            venv = ".venv";
            lint = true;
            inlayHint.enable = true;
            autoSearchPaths = true;
            diagnosticMode = "workspace";
            useLibraryCodeForType = true;
            logLevel = "Error";
            typeCheckingMode = "off";
            autoImoprtCompletion = true;
            reportOptionalSubscript = false;
            reportOptionalMemberAccess = false;
          };
        };
        ruff = {
          command = "ruff";
          args = ["server"];
          environment = {RUFF_TRACE = "messages";};
        };
      };
    };
  };
}
