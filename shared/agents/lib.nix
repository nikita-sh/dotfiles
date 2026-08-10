{ lib, pkgs }:
{
  # Options every harness accepts. Each harness module translates these into
  # its own native keys; nothing here is passed through verbatim.
  harnessOptions =
    { name, ... }:
    {
      options = {
        enable = lib.mkEnableOption "the ${name} coding agent";

        model = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Model identifier, in whatever form ${name} expects. Not validated against a catalog.";
        };

        reasoningEffort = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.enum [
              "off"
              "minimal"
              "low"
              "medium"
              "high"
              "xhigh"
            ]
          );
          default = null;
          description = "Normalized reasoning effort. A harness that cannot express the chosen value fails during evaluation.";
        };

        theme = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        extraInstructions = lib.mkOption {
          type = lib.types.either lib.types.lines lib.types.path;
          default = "";
          description = "Appended after the shared body and the harness's own instruction file.";
        };

        settings = lib.mkOption {
          type = (pkgs.formats.json { }).type;
          default = { };
          description = "Raw harness-native settings, merged last. Escape hatch for anything the normalized options do not cover.";
        };
      };
    };

  # Translate a normalized reasoningEffort through a harness lookup table.
  # An absent key throws rather than silently dropping the setting.
  mapEffort =
    harness: table: value:
    if value == null then
      null
    else
      table.${value}
        or (throw "my.agents: harness ${harness} cannot express reasoningEffort \"${value}\"");

  mkInstructions =
    name: parts:
    let
      render = part: if lib.isPath part then builtins.readFile part else part;
      rendered = lib.filter (s: s != "") (map render parts);
    in
    pkgs.writeText "${name}-instructions.md" (lib.concatStringsSep "\n\n---\n\n" rendered);

  # For settings files the agent rewrites at runtime. A store symlink cannot be
  # used: the agent writes a temporary file next to the resolved symlink target
  # and renames it, which fails inside the store. Precedence is
  # defaults < whatever the agent wrote < nix-managed keys. jq `*` merges
  # objects and replaces arrays, so a managed array replaces wholesale.
  # `format = "toml"` merges through JSON and converts back; comments and key
  # order in the existing file are not preserved.
  mkMutableSettings =
    {
      path,
      format ? "json",
      defaults ? { },
      managed ? { },
    }:
    let
      jsonFmt = pkgs.formats.json { };
      defaultsJson = jsonFmt.generate "agents-defaults.json" defaults;
      managedJson = jsonFmt.generate "agents-managed.json" managed;
      remarshal = lib.getExe pkgs.remarshal;
      toJson = if format == "toml" then "${remarshal} --if toml --of json" else "cat";
      fromJson = if format == "toml" then "${remarshal} --if json --of toml" else "cat";
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      target="$HOME/${path}"
      run mkdir -p "$(dirname "$target")"
      # Older generations may have left a store symlink here.
      if [ -L "$target" ]; then run rm -f "$target"; fi
      existing='{}'
      # An unparseable existing file aborts activation rather than being
      # overwritten: losing runtime state silently is the worse outcome.
      if [ -s "$target" ]; then existing="$(${toJson} < "$target")"; fi
      printf '%s' "$existing" \
        | ${pkgs.jq}/bin/jq -S \
            --slurpfile d ${defaultsJson} \
            --slurpfile m ${managedJson} \
            '$d[0] * . * $m[0]' \
        | ${fromJson} > "$target.tmp"
      # Codex creates config.toml 0600; a rebuild must not widen it.
      run chmod 600 "$target.tmp"
      run mv "$target.tmp" "$target"
    '';
}
