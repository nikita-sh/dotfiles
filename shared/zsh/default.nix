{
  pkgs,
  lib,
  system,
  hostname ? "",
  sessionVariables ? { },
  p10k ? ./foo.zsh,
  ...
}:
{
  home.file.".p10k.zsh".source = p10k;

  programs.zsh = {
    inherit sessionVariables;

    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "alias-finder"
        "fzf"
        "colored-man-pages"
        "direnv"
        "rust"
        "systemd"
        "tailscale"
        "nmap"
        "kitty"
        "colorize"
        "colored-man-pages"
        "direnv"
        "rust"
        "systemd"
        "tailscale"
        "nmap"
        "kitty"
        "colorize"
      ];
    };

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        DISABLE_MAGIC_FUNCTIONS=true
        export "MICRO_TRUECOLOR=1"
      '')
      (lib.mkAfter ''
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      '')
    ];

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

    shellAliases = {
      # Utils
      c = "clear";
      cd = "z";
      cat = "bat";
      nano = "micro";
      icat = "kitten icat";
      dsize = "du -hs";
      findw = "grep -rl";
      s = "kitten ssh";
      diff = "delta";
      t = "task";
      gpt = "chatgpt";
      nf = "neofetch";

      # Nixos
      ns = "nix-shell --run zsh -p";
      nix-shell = "nix-shell --run zsh";
      nix-flake-update = "sudo nix flake update ~/dotfiles#";
      nix-clean = ''
        sudo nix-collect-garbage && sudo nix-collect-garbage -d \
        && sudo rm /nix/var/nix/gcroots/auto/* && nix-collect-garbage \
        && nix-collect-garbage -d
      '';
      nixosrb =
        let
          cmd = if system == "darwin" then "nix run nix-darwin" else "nixos-rebuild";
        in
        "sudo ${cmd} --flake ~/dev/dotfiles/systems/${hostname}#${hostname}";

      # home manager
      hmrb = "home-manager --flake ~/dev/dotfiles/homes/${hostname}#nikita@${hostname}";

      # Git
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gs = "git status";
      gb = "git branch";
      gm = "git merge";
      gmc = "git merge --continue";
      gma = "git merge --abort";
      gp = "git pull";
      gpo = "git pull origin";
      gps = "git push";
      gpst = "git push --follow-tags";
      gpso = "git push origin";
      gc = "git commit";
      gcf = "git commit --fixup";
      gcm = "git commit -m";
      gtag = "git tag -ma";
      gco = "git checkout";
      gcob = "git checkout -b";
      gcoe = "git config user.email";
      gcon = "git config user.name";
      gca = "git commit --amend";
      gpfwl = "git push --force-with-lease";
      gpr = "git pull --rebase";
      gst = "git stash";
      gstp = "git stash pop";
      gl = "git log";
      glp = ''
        git log --graph --abbrev-commit --decorate \ 
        --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' \
        --all
      '';
      grl = "git reflog";
      gd = "git diff";
      grb = "git rebase";
      grbc = "git rebase --continue";
      grba = "git rebase --abort";
      grbi = "git rebase -i";
      gsh = "git show";
      gcp = "git cherry-pick";
      gcpc = "git cherry-pick --continue";
      gcpa = "git cherry-pick --abort";
      grbias = "git rebase -i --autosquash";

      # fw
      pbrun-atsam18 = "sudo probe-rs run --chip ATSAMD51J18A";
      pbrun-atsam20 = "sudo probe-rs run --chip ATSAMD51J20A";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
