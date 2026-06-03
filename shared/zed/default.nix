{ ... }:
{
  programs.zed-editor = {
    enable = true;
    extraPackages = [
      "grubox-ish"
    ];

    userSettings = {
      assistant = {
        enabled = true;
        default_model = {
          provider = "anthropic";
          model = "claude-3-opus-latest";
        };
      };

      hour_format = "hour24";
      auto_update = false;
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      vim_mode = true;

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
      };

      lsp = {
        nix = {
          binary = {
            path_lookup = true;
          };
        };
      };
    };
  };
}
