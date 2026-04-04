{ inputs, pkgs, ... }:
{
  imports = [ inputs.vscode-server.homeModules.default ];
  services.vscode-server.enable = true;

  home.file.".vscode-server/data/Machine/settings.json".text = builtins.toJSON {
    "claude.executablePath" = "${pkgs.claude-code}/bin/claude";
    "nix.enableLanguageServer" = true;
  };
}
