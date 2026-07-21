{ pkgs, lib, ... }:
let
  claude-code-log = pkgs.python3Packages.callPackage ./claude-code-log.nix { };
  dcg = pkgs.callPackage ./dcg.nix { };

  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [
      pkgs.jq
      pkgs.git
    ];
    text = builtins.readFile ./statusline-command.sh;
  };

  optionalDir = dir: if builtins.pathExists dir then dir else null;
in
{
  home.packages = [
    claude-code-log
    dcg # also on PATH for manual testing: `echo '{"tool_name":...}' | dcg`
  ];

  programs.claude-code = {
    enable = true;

    # ~/.claude/CLAUDE.md
    memory.source = ./claude.md;

    # Repo-owned customizations, symlinked into ~/.claude/. Dropping a new
    # skills/<name>/SKILL.md (or agents/commands/hooks file) is all that's
    # needed - no extra wiring.
    skillsDir = ./skills;
    agentsDir = optionalDir ./agents;
    commandsDir = optionalDir ./commands;
    hooksDir = optionalDir ./hooks;

    settings = {
      model = "claude-opus-4-8[1m]";
      effortLevel = "high";
      theme = "dark-ansi";
      skipWorkflowUsageWarning = true;

      permissions = {
        defaultMode = "acceptEdits";
        # Bare "Bash" auto-approves every shell command; the dcg PreToolUse
        # hook below stays in front of them as the destructive-command guard
        # (hook denials override permission allows).
        allow = [ "Bash" ];
      };

      statusLine = {
        type = "command";
        command = lib.getExe statusline;
      };

      hooks.PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = lib.getExe dcg;
            }
          ];
        }
      ];
    };
  };
}
