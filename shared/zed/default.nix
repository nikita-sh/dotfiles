{ ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "toml"
      "haskell"
      "make"
      "gruvbox-ish"
    ];

    userSettings = {
      disable_ai = false;
      agent = {
        default_model = {
          provider = "anthropic";
          model = "claude-opus-4-latest";
        };
      };

      hour_format = "hour24";
      auto_update = false;
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      vim_mode = true;

      ui_font_size = 13;
      buffer_font_size = 13;
      buffer_font_family = "FiraCode Nerd Font";
      buffer_font_features = {
        calt = true;
        clig = true;
        liga = true;
      };
      show_whitespaces = "all";
      relative_line_numbers = "enabled";

      wrap_guides = [
        80
        120
      ];
      ensure_final_newline_on_save = true;
      remove_trailing_whitespace_on_save = true;

      terminal = {
        copy_on_select = false;
        dock = "bottom";
        env = {
          TERM = "wezterm";
        };
        font_family = "FiraCode Nerd Font";
        font_features = null;
        font_size = null;
        line_height = "comfortable";
        option_as_meta = false;
        button = false;
        shell = {
          program = "zsh";
        };
        toolbar = {
          title = true;
        };
        working_directory = "current_project_directory";
        max_scroll_history_lines = 10000;
      };

      lsp = {
        hls = {
          binary = {
            path = "haskell-language-server-wrapper";
          };
        };

        rust-analyzer = {
          initialization_options = {
            cargo = {
              features = "all";
            };
            rust = {
              analyzerTargetDir = true;
            };
            check = {
              command = "check";
            };
          };
        };
      };
    };
  };
}
