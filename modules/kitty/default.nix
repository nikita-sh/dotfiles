{ pkgs, ... }: {
  programs.kitty = {
    enable = true;

    theme = "Gruvbox Dark";

    font = {
      name = "FiraCode Nerd Font";
      size = 11;
    };

    settings = {
      confirm_os_window_close = 0;
      background_opacity = "0.8";
      window_padding_width = 0;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      mouse_hide_wait = 60;

      ## Tabs
      tab_title_template = "{index}";
      active_tab_font_style = "normal";
      inactive_tab_font_style = "normal";
      active_tab_foreground = "#ebdbb2";
      active_tab_background = "#d65d0e";
      inactive_tab_foreground = "#282828";
      inactive_tab_background = "#ebdbb2";
    };

    keybindings = {
      ## Tabs
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
      "alt+6" = "goto_tab 6";
      "alt+7" = "goto_tab 7";
      "alt+8" = "goto_tab 8";
      "alt+9" = "goto_tab 9";

      ## Unbind
      # "ctrl+shift+left" = "no_op";
      # "ctrl+shift+right" = "no_op";
    };
  };
}
