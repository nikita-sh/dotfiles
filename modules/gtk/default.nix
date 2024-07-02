{ pkgs, ... }:
let gbox-gtk = import ../themes/gruvbox/default.nix { inherit pkgs; };
in {
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.nerdfonts
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
    pkgs.twemoji-color-font
    pkgs.noto-fonts-emoji
  ];

  gtk = {
    enable = true;
    font = {
      name = "FiraCode";
      size = 11;
    };

    # iconTheme = {
    #   name = "Papirus-Dark";
    #   package = pkgs.papirus-icon-theme;
    # };

    iconTheme = {
      name = "Gruvbox-Dark";
      package = gbox-gtk;
    };

    theme = {
      name = "Gruvbox-Dark-BL";
      package = gbox-gtk;
      # package = pkgs.catppuccin-gtk.override {
      #   accents = [ "lavender" ];
      #   size = "compact";
      #   # tweaks = [ "rimless" ];
      #   variant = "mocha";
      # };
    };
    cursorTheme = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      size = 22;
    };
  };

  home.pointerCursor = {
    name = "Nordzy-cursors";
    package = pkgs.nordzy-cursor-theme;
    size = 22;
  };
}
