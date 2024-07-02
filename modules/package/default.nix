{ inputs, pkgs, ... }: {
  home.packages = (with pkgs;
    with gnome; [
      _1password # 1password cli + gui
      _1password-gui
      ani-cli # animu
      bitwise # cli tool for bit / hex manipulation
      entr # perform action when file change
      file # Show file information
      delta
      fzf # fuzzy finder
      lazygit
      nitch # systhem fetch util
      nix-prefetch-github
      pipx # Install Python applications in isolated environments
      prismlauncher # minecraft launcher
      ripgrep # grep replacement
      todo # cli todo list
      toipe # typing test in the terminal
      cinnamon.nemo-with-extensions # file manager
      yazi # terminal file manager
      youtube-dl
      gnome.zenity

      # C / C++
      gcc
      gnumake

      bleachbit # cache cleaner
      cmatrix
      gparted # partition manager
      ffmpeg
      imv # image viewer
      libnotify
      man-pages # extra man pages
      mpv # video player
      ncdu # disk space
      openssl
      pamixer # pulseaudio command line mixer
      pavucontrol # pulseaudio volume controle (GUI)
      playerctl # controller for media players
      httpie
      qalculate-gtk # calculator
      unzip
      wget
      xdg-utils
      inputs.alejandra.defaultPackage.${system}
      cargo
      direnv
      nmap
      neofetch
      pstree
      qemu
      rustc
      starfetch
      zoom-us
      sway-contrib.grimshot

      # gnome stuff
      gnome-weather
      gnome-calculator

      xwaylandvideobridge
      screen
      jq
      firefox
      calcurse
      vim # just in case
      probe-rs
      balena-cli
      bitwarden
    ]);
}
