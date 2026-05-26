{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.nix-vscode-extensions.vscode-marketplace; [
        anthropic.claude-code
        vscodevim.vim
        eamodio.gitlens
        github.vscode-pull-request-github
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
        zxh404.vscode-proto3
        jdinhlife.gruvbox
        sainnhe.gruvbox-material
        sumneko.lua
      ];
      userSettings = {
        "editor.fontFamily" = "'FiraCode Nerd Font', Menlo, Monaco, 'Courier New', monospace";
        "editor.fontSize" = 13;
        "editor.fontLigatures" = true;
        "git.openRepositoryInParentFolders" = "always";
        "window.titleBarStyle" = "custom";
        "workbench.colorTheme" = "Gruvbox Dark Hard";
        "files.insertFinalNewline" = true;
        "files.watcherExclude" = {
          "**/.git/objects/**" = true;
          "**/.git/subtree-cache/**" = true;
          "**/node_modules/*/**" = true;
        };
        "window.zoomLevel" = 0;
        "gitlens.launchpad.indicator.enabled" = false;
        "gitlens.launchpad.indicator.polling.enabled" = false;
        "gitlens.plusFeatures.enabled" = false;
        "gitlens.showWhatsNewAfterUpgrades" = false;
        "gitlens.telemetry.enabled" = false;
        "haskell.manageHLS" = "PATH";
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "nixfmt";
        "nix.serverPath" = "nil";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = [
                "nixfmt"
              ];
            };
          };
        };
        "search.useGlobalIgnoreFiles" = true;
        "search.useParentIgnoreFiles" = true;
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.scrollback" = 10000;
        "editor.lineNumbers" = "relative";
        "rust-analyzer.cargo.features" = "all";
        "rust-analyzer.cachePriming.enable" = true;
        "rust-analyzer.cargo.targetDir" = true;
        "rust-analyzer.check.command" = "check";
        "extensions.verifySignature" = false;
      };
    };
  };
}
