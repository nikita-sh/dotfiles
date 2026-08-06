{
  pkgs,
  lib,
  config,
  inputs,
  agentsLib,
  ...
}:
let
  cfg = config.my.agents;
  # `harnesses` is attrsOf, so an unmentioned harness has no attribute at all.
  hcfg = cfg.harnesses.codex or null;
  enabled = hcfg != null && hcfg.enable;

  # release-25.11 has codex 0.92.0, below the 0.125.0 floor for PreToolUse
  # hooks and the 0.94.0 floor for reading ~/.agents/skills.
  codexPkg = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.codex;

  effort = agentsLib.mapEffort "codex" {
    minimal = "minimal";
    low = "low";
    medium = "medium";
    high = "high";
  } hcfg.reasoningEffort;

  instructions = agentsLib.mkInstructions "codex" [
    cfg.instructions
    ./codex/instructions.md
    hcfg.extraInstructions
  ];
in
{
  config = lib.mkIf enabled {
    programs.codex = {
      enable = true;
      package = codexPkg;
      custom-instructions = builtins.readFile instructions;

      settings =
        lib.filterAttrs (_: v: v != null) {
          model = hcfg.model;
          model_reasoning_effort = effort;
        }
        // hcfg.settings;
    };

    # programs.codex manages config.toml and rules, not hooks.json. The file
    # already exists on machines where dcg's own installer ran, so it is merged
    # rather than symlinked: that replaces dcg's path with the store path and
    # leaves unrelated hook entries alone.
    home.activation.codexHooks = lib.mkIf cfg.guard.enable (
      agentsLib.mkMutableSettings {
        path = ".codex/hooks.json";
        managed = {
          hooks.PreToolUse = [
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
        };
      }
    );
  };
}
