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
        # hashicorp.terraform
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
        jdinhlife.gruvbox
        catppuccin.catppuccin-vsc
        sainnhe.gruvbox-material
        github.copilot
        ms-python.vscode-pylance
        raspberry-pi.raspberry-pi-pico
        paulober.pico-w-go
        twxs.cmake
        # ms-vscode.cpptools
        ms-vscode.cmake-tools
        ms-vscode.cpptools-extension-pack
        ms-vscode.vscode-serial-monitor
        marus25.cortex-debug
        mcu-debug.debug-tracker-vscode
        mcu-debug.memory-view
        mcu-debug.peripheral-viewer
        mcu-debug.rtos-views
        rhaiscript.vscode-rhai
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
        # "nix.formatterPath" = "nixfmt";
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
        # "rust-analyzer.cargo.features" = "all";
        "rust-analyzer.cachePriming.enable" = true;
        "rust-analyzer.cargo.targetDir" = true;
        "rust-analyzer.check.command" = "check";
        "extensions.verifySignature" = false;
        "parallels-desktop.extension.path" = "/Users/nikita/.parallels-desktop-vscode";
        "parallels-desktop.devops-service.path" = "/Users/nikita/.parallels-desktop-vscode/tools/prldevops";
        "parallels-desktop.prlctl.path" = "/usr/local/bin/prlctl";
        "parallels-desktop.brew.path" = "/opt/homebrew/bin/brew";
        "parallels-desktop.git.path" = "/Users/nikita/.nix-profile/bin/git";
        "protobuf.autoDetection.prompted" = false;
        "protobuf.autoDetection.enabled" = false;
        "protobuf.binaryInspector.enabled" = false;
        "protobuf.codegen.generateOnSave" = false;
      };
    };
  };
}
