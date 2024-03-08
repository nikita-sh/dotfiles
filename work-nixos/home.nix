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
    ../user/tmux.nix
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
        # obsidian
        awscli2
	      ripgrep
        bat
        btop
        cargo
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
        neofetch
        pstree
        qemu
        ripgrep
        rsync
        rustc
        screen
        spotify
        slack
        stdenv.cc
        strace
        terraform
        tmux
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
  # home.packages = with pkgs; [ steam ];
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
      shellAliases = {
        g = "git";
        nvim = "nix run /home/nikita/dev/nix-env#neovim --";
      };
      plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "zsh-nix-shell";
            file = "nix-shell.plugin.zsh";
            src = pkgs.fetchFromGitHub {
              owner = "chisui";
              repo = "zsh-nix-shell";
              rev = "v0.8.0";
              sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
            };
          }
      ];
      initExtra = ''
        source /home/nikita/dev/nix-env/dot/dot-p10k.zsh
        prompt_nix_shell_setup
      '';
    #   initExtra = ''
    #     # Powerlevel10k Zsh theme  
    #     source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme  
    #     test -f ~/dev/dotfiles/dot/dot-p10k.zsh && ~/dev/dotfiles/dot/dot-p10k.zsh 
    #   '';
    };
  };

#   home.file.".zshrc".source = ./dot/dot-zshrc;
  home.file.".p10k.zsh".source = ../dot/dot-p10k.zsh;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
