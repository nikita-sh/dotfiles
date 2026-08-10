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

      # Left empty so the module writes no config.toml. Codex rewrites that file
      # itself (model choice, plugin registry, project trust, hook trust
      # hashes), so it is merged below instead of symlinked from the store.
      settings = { };
    };

    home.activation.codexConfig = agentsLib.mkMutableSettings {
      path = ".codex/config.toml";
      format = "toml";
      defaults = lib.filterAttrs (_: v: v != null) {
        model = hcfg.model;
        model_reasoning_effort = effort;
      };
      managed = hcfg.settings;
    };

    # hooks.json already exists on machines where dcg's own installer ran, so it
    # is merged rather than symlinked: that replaces dcg's path with the store
    # path and leaves unrelated hook entries alone.
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
