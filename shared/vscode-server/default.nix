{ inputs, config, ... }:
{
  imports = [ inputs.vscode-server.homeModules.default ];
  services.vscode-server.enable = true;

  home.file.".vscode-server/data/Machine/settings.json".text = builtins.toJSON {
    "claudeCode.claudeProcessWrapper" = "${config.programs.claude-code.package}/bin/claude";
    "nix.enableLanguageServer" = true;
    "direnv.path.executable" = "direnv";
  };
}
