{pkgs, ...}:
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      jdinhlife.gruvbox
      eamodio.gitlens
      github.vscode-pull-request-github
      hashicorp.terraform
      haskell.haskell
      jnoortheen.nix-ide
      mechatroner.rainbow-csv
      mhutchie.git-graph
      mkhl.direnv
      ms-python.python
      ms-vscode.makefile-tools
      ms-vscode.powershell
      ms-vscode-remote.remote-ssh
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      vscodevim.vim
      zxh404.vscode-proto3
    ];
    userSettings = {
      "window.titleBarStyle" = "custom";
      "workbench.colorTheme" = "Gruvbox Dark Hard";
      "workbench.iconTheme" = "Monokai Classic Icons";
    };
  };
}
