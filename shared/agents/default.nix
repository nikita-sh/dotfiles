{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.agents;
  agentsLib = import ./lib.nix { inherit lib pkgs; };
in
{
  imports = [
    ./harnesses/claude-code.nix
    ./harnesses/codex.nix
  ];

  options.my.agents = {
    instructions = lib.mkOption {
      type = lib.types.either lib.types.lines lib.types.path;
      default = ./instructions.md;
      description = "Harness-neutral instruction body, rendered into every enabled harness.";
    };

    skillsDir = lib.mkOption {
      type = lib.types.path;
      default = ./skills;
      description = "Single skills source. Every harness reads the same directory.";
    };

    guard = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Wire the destructive-command guard into every enabled harness.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.callPackage ./guard/dcg.nix { };
      };
    };

    harnesses = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule agentsLib.harnessOptions);
      default = { };
    };
  };

  config = {
    # Nested under config, not top level: the module system rejects a bare
    # `_module` attribute in a module that also has an explicit `config` block.
    _module.args.agentsLib = agentsLib;

    # On PATH for manual testing: `echo '{"tool_name":...}' | dcg`
    home.packages = lib.optional cfg.guard.enable cfg.guard.package;

    # Codex from 0.94 and Prime Agent both read this location.
    home.file.".agents/skills".source = cfg.skillsDir;
  };
}
