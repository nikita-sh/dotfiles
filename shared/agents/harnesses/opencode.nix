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
  hcfg = cfg.harnesses.opencode or null;
  enabled = hcfg != null && hcfg.enable;

  opencodePkg = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode;

  instructions = agentsLib.mkInstructions "opencode" [
    cfg.instructions
    ./opencode/instructions.md
    hcfg.extraInstructions
  ];

  managedSettings = {
    "$schema" = "https://opencode.ai/config.json";
    permission = {
      edit = "allow";
      # Without the plugin, OpenCode must retain its own shell approval boundary.
      bash = if cfg.guard.enable then "allow" else "ask";
    };
  }
  // hcfg.settings;
in
{
  config = lib.mkIf enabled {
    assertions = [
      {
        assertion = hcfg.reasoningEffort == null;
        message = "my.agents: harness opencode cannot express reasoningEffort independently of its model";
      }
    ];

    programs.opencode = {
      enable = true;
      package = opencodePkg;
      rules = builtins.readFile instructions;

      # OpenCode may update its global config, so activation merges it below.
      settings = { };
    };

    home.activation.opencodeConfig = agentsLib.mkMutableSettings {
      path = ".config/opencode/opencode.json";
      defaults = lib.optionalAttrs (hcfg.model != null) { model = hcfg.model; };
      managed = managedSettings;
    };

    home.activation.opencodeTui = lib.mkIf (hcfg.theme != null) (agentsLib.mkMutableSettings {
      path = ".config/opencode/tui.json";
      defaults = { theme = hcfg.theme; };
    });

    xdg.configFile."opencode/plugins/dcg-guard.js" = lib.mkIf cfg.guard.enable {
      source = ./opencode/dcg-guard.js;
    };
  };
}
