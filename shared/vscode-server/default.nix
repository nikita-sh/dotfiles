{ inputs, pkgs, ... }:
{
  imports = [ inputs.vscode-server.homeModules.default ];
  services.vscode-server.enable = true;

  home.file.".vscode-server/data/Machine/settings.json".text = builtins.toJSON {
    "claudeCode.claudeProcessWrapper" = "${pkgs.claude-code}/bin/claude";
    "nix.enableLanguageServer" = true;
    "direnv.path.executable" = "direnv";
  };
}
