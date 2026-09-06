{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.my.agents;
  agentsLib = import ./lib.nix { inherit lib pkgs; };

  # The upstream skills address each other as `superpowers:<name>`, which only
  # resolves when superpowers is installed as a plugin. These are installed as
  # personal skills, where the name is bare.
  superpowersSkills = pkgs.runCommand "superpowers-skills" { } ''
    cp -r ${inputs.superpowers}/skills $out
    chmod -R u+w $out
    find $out -type f -name '*.md' -exec sed -i 's/superpowers://g' {} +
  '';

  skills = pkgs.runCommand "agent-skills" { } ''
    mkdir -p $out
    ${lib.concatMapStringsSep "\n" (dir: "cp -r ${dir}/* $out/") (
      [ cfg.skillsDir ] ++ lib.optional cfg.superpowers.enable superpowersSkills
    )}
    chmod -R u+w $out
  '';
in
{
  imports = [
    ./harnesses/claude-code.nix
    ./harnesses/codex.nix
    ./harnesses/omp.nix
    ./harnesses/opencode.nix
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
      description = "Repo-owned skills. Merged with any imported set into the single directory every harness reads.";
    };

    superpowers.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add the obra/superpowers skills, and the session-start bootstrap that introduces them.";
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
    _module.args.agentSkills = skills;

    # On PATH for manual testing: `echo '{"tool_name":...}' | dcg`
    home.packages = lib.optional cfg.guard.enable cfg.guard.package;

    # Codex reads this location from 0.94.
    home.file.".agents/skills".source = skills;
  };
}
