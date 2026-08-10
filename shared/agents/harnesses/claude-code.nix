{
  pkgs,
  lib,
  config,
  agentsLib,
  agentSkills,
  ...
}:
let
  cfg = config.my.agents;
  # `harnesses` is attrsOf, so an unmentioned harness has no attribute at all.
  hcfg = cfg.harnesses.claude-code or null;
  enabled = hcfg != null && hcfg.enable;

  claude-code-log = pkgs.python3Packages.callPackage ./claude-code/claude-code-log.nix { };

  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [
      pkgs.jq
      pkgs.git
    ];
    text = builtins.readFile ./claude-code/statusline-command.sh;
  };

  optionalDir = dir: if builtins.pathExists dir then dir else null;

  # Replaces what the superpowers plugin's own SessionStart hook did: put the
  # using-superpowers skill in front of the model at the start of every session.
  superpowersPreamble = ''
    <EXTREMELY_IMPORTANT>
    You have superpowers.

    **Below is the full content of your 'using-superpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**

  '';

  superpowersBootstrap = pkgs.writeShellApplication {
    name = "superpowers-session-start";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      jq -n \
        --rawfile skill ${agentSkills}/using-superpowers/SKILL.md \
        --arg pre ${lib.escapeShellArg superpowersPreamble} \
        --arg post ${lib.escapeShellArg "\n</EXTREMELY_IMPORTANT>"} \
        '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ($pre + $skill + $post)}}'
    '';
  };

  effort = agentsLib.mapEffort "claude-code" {
    low = "low";
    medium = "medium";
    high = "high";
    xhigh = "xhigh";
  } hcfg.reasoningEffort;

  instructions = agentsLib.mkInstructions "claude-code" [
    cfg.instructions
    ./claude-code/instructions.md
    hcfg.extraInstructions
  ];

  managedHooks =
    lib.optionalAttrs cfg.guard.enable {
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = lib.getExe cfg.guard.package;
            }
          ];
        }
      ];
    }
    // lib.optionalAttrs cfg.superpowers.enable {
      SessionStart = [
        {
          matcher = "startup|clear|compact";
          hooks = [
            {
              type = "command";
              command = lib.getExe superpowersBootstrap;
            }
          ];
        }
      ];
    };

  # Policy plus store-path keys: nix always wins, refreshed every rebuild.
  managedSettings = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    skipWorkflowUsageWarning = true;
    permissions = {
      defaultMode = "acceptEdits";
      # Bare "Bash" auto-approves every shell command; the dcg PreToolUse hook
      # stays in front as the destructive-command guard (hook denials override
      # permission allows).
      allow = [ "Bash" ];
    };
    statusLine = {
      type = "command";
      command = lib.getExe statusline;
    };
  }
  // lib.optionalAttrs (managedHooks != { }) { hooks = managedHooks; }
  // hcfg.settings;

  # Seeded on first run; Claude may overwrite these at runtime (/effort, /model,
  # /config) and the overwrite survives rebuilds via the activation merge.
  defaultSettings = lib.filterAttrs (_: v: v != null) {
    model = hcfg.model;
    effortLevel = effort;
    theme = hcfg.theme;
  };
in
{
  config = lib.mkIf enabled {
    home.packages = [ claude-code-log ];

    programs.claude-code = {
      enable = true;

      memory.source = instructions;

      # Repo-owned customizations, symlinked into ~/.claude/. Dropping a new
      # skills/<name>/SKILL.md (or agents/commands/hooks file) is all that's
      # needed - no extra wiring.
      skillsDir = agentSkills;
      agentsDir = optionalDir ./claude-code/agents;
      commandsDir = optionalDir ./claude-code/commands;
      hooksDir = optionalDir ./claude-code/hooks;

      # Written by the activation merge below, not the module, so the file
      # stays writable for runtime settings changes.
      settings = { };
    };

    home.activation.claudeSettings = agentsLib.mkMutableSettings {
      path = ".claude/settings.json";
      defaults = defaultSettings;
      managed = managedSettings;
    };
  };
}
