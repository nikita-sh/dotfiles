{ pkgs, ... }:
{
  programs.btop = {
    enable = true;

    settings = {
      color_theme = "gruvbox";
      theme_background = false;
      update_ms = 500;
    };
  };
}
