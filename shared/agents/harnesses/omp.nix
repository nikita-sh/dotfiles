{
  lib,
  config,
  inputs,
  agentsLib,
  ...
}:
let
  cfg = config.my.agents;
  # `harnesses` is attrsOf, so an unmentioned harness has no attribute at all.
  hcfg = cfg.harnesses.omp or null;
  enabled = hcfg != null && hcfg.enable;

  effort = agentsLib.mapEffort "omp" {
    minimal = "minimal";
    low = "low";
    medium = "medium";
    high = "high";
    xhigh = "xhigh";
  } hcfg.reasoningEffort;

  instructions = agentsLib.mkInstructions "omp" [
    cfg.instructions
    hcfg.extraInstructions
  ];

  defaultSettings =
    lib.optionalAttrs (hcfg.model != null) {
      modelRoles.default = hcfg.model;
    }
    // lib.optionalAttrs (effort != null) {
      defaultThinkingLevel = effort;
    }
    // lib.optionalAttrs (hcfg.theme != null) {
      theme.dark = hcfg.theme;
    };
in
{
  imports = [ inputs.omp.homeManagerModules.default ];

  config = lib.mkIf enabled {
    programs.omp.enable = true;

    # Native user instructions take precedence over foreign harness files that
    # OMP can discover from ~/.claude, ~/.codex, and similar directories.
    home.file.".omp/agent/AGENTS.md".source = instructions;

    # Leave programs.omp.settings unset: the upstream activation replaces the
    # entire writable file, while OMP persists runtime choices into that file.
    home.activation.ompHarnessConfig = agentsLib.mkMutableSettings {
      path = ".omp/agent/config.yml";
      format = "yaml";
      fallbackPaths = [ ".omp/agent/config.yaml" ];
      defaults = defaultSettings;
      managed = hcfg.settings;
    };
  };
}
