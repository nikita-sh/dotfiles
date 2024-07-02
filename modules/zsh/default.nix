{ hostname, config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "fzf" ];
    };
    initExtraFirst = ''
      DISABLE_MAGIC_FUNCTIONS=true
      export "MICRO_TRUECOLOR=1"
    '';
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
      source /home/nikita/dev/nixos-config/modules/home/zsh/dot-p10k.zsh && ${pkgs.openssh}/bin/ssh-add /home/nikita/.ssh/id_rsa
    '';
    shellAliases = {
      # record = "wf-recorder --audio=alsa_output.pci-0000_08_00.6.analog-stereo.monitor -f $HOME/Videos/$(date +'%Y%m%d%H%M%S_1.mp4')";

      # Utils
      c = "clear";
      cd = "z";
      # vim = "nvim";
      cat = "bat";
      ls = "lsd";
      nano = "micro";
      icat = "kitten icat";
      dsize = "du -hs";
      findw = "grep -rl";
      nvim = "nix run /home/nikita/dev/nixos-config#neovim --";
      s = "kitten ssh";
      diff = "delta";
      t = "task";
      gpt = "chatgpt";
      nf = "neofetch";

      # Nixos
      cdnix = "cd ~/nixos-config && codium ~/nixos-config";
      ns = "nix-shell --run zsh -p";
      nix-shell = "nix-shell --run zsh";
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      nix-switchu =
        "sudo nixos-rebuild switch --upgrade --flake ~/nixos-config#nixos";
      nix-flake-update = "sudo nix flake update ~/nixos-config#";
      nix-clean =
        "sudo nix-collect-garbage && sudo nix-collect-garbage -d && sudo rm /nix/var/nix/gcroots/auto/* && nix-collect-garbage && nix-collect-garbage -d";
      # nix-clean = "sudo nix-collect-garbage -d";
      # nix-cleanold = "sudo nix-collect-garbage --delete-old";
      # nix-cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";

      # Git
      ga = "git add";
      gaa = "git add --all";
      gs = "git status";
      gb = "git branch";
      gm = "git merge";
      gpl = "git pull";
      gplo = "git pull origin";
      gps = "git push";
      gpst = "git push --follow-tags";
      gpso = "git push origin";
      gc = "git commit";
      gcm = "git commit -m";
      gtag = "git tag -ma";
      gch = "git checkout";
      gchb = "git checkout -b";
      gcoe = "git config user.email";
      gcon = "git config user.name";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
