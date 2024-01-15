# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
    #   outputs.overlays.additions
    #   outputs.overlays.modifications
    #   outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = "nikita";
    homeDirectory = "/home/nikita";
    packages = with pkgs; [
        obsidian
        awscli2
	    ripgrep
        bat
        btop
        ctags
        delta
        direnv
        dnsutils
        easyrsa
        fd
        file
        firefox
        gnumake
        glow
        helix
        iftop
        iotop
        ipcalc
        iperf3
        keychain
        linuxHeaders
        nmap 
        openssh
        openssl
        openssl.dev
        pkg-config
        mtr 
        neovim
        neofetch
        pstree
        qemu
        ripgrep
        rsync
        screen
        spotify
        slack
        stdenv.cc
        strace
        terraform
        unzip
        vscode
        xxd
        zip
        binutils
        usbutils
        libftdi
        libusb
        zoom-us
    ];
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
        package = pkgs.git;
        enable = true;
        userName = "Nikita Shumeiko";
        aliases = {
            p = "pull";
            pr = "pull --rebase";
            psh = "push";
            ci = "commit";
            ca = "commit --amend";
            cim = "commit -m";
            s = "status";
            st = "stash";
            pfwl = "push --force-with-lease";
            co = "checkout";
	        cob = "checkout -b";
            r = "rebase";
            rbi = "rebase -i";
            a = "add";
            sp = "stash pop";
            cp = "cherry-pick";
            l = "log";
            d = "diff";
            rl = "reflog";
            m = "merge";
        };
        extraConfig = {
            core.editor = "$EDITOR";
            core.pager = "${pkgs.delta}/bin/delta";
            interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
            add.interactive.useBuiltin = false;
            delta = {
                features = "chameleon";
                side-by-side = false;
                navigate = true;
                light = false;
            };
            merge.conflictstyle = "diff3";
            diff.colorMoved = "default";
        };
    };

    jq.enable = true;
    man.enable = true;

    zsh = {
      enable = true;
      defaultKeymap = "vicmd";
      shellAliases = {
        g = "git";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
        ];
        theme = "powerlevel10k/powerlevel10k";
      };
    };

    neovim.plugins = [
        pkgs.vimPlugins.gruvbox
        pkgs.vimPlugins.ale
        pkgs.vimPlugins.vim-fugitive
        pkgs.vimPlugins.nerdtree
        pkgs.vimPlugins.syntastic
        pkgs.vimPlugins.vim-surround
        pkgs.vimPlugins.vim-airline
    ];
  };

  home.file.".zshrc".source = ./dot/dot-zshrc;
  home.file.".p10k.zsh".source = ./dot/dot-p10k.zsh;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
