---
name: self-reflect
description: Analyze recent Claude Code sessions for recurring interaction patterns, then propose skills, CLAUDE.md rules, or settings changes to add to the nix dotfiles. Use when asked to review past sessions, find patterns in how we work together, or figure out what should become a skill.
---

# Self-reflection over session transcripts

Transcripts live in `~/.claude/projects/<slugified-cwd>/<session-uuid>.jsonl`, one JSON object per line. Subagent transcripts are under `<session-uuid>/subagents/agent-*.jsonl` — exclude them, they reflect prompts you wrote, not the user's.

The full set is far too large to read directly (a few weeks of sessions is hundreds of megabytes). Extract and condense first, then read the condensed output.

## Extraction

Write extraction commands to a script file under `/tmp/claude/` and run the file. Passing a multi-line `jq` program inline through the Bash tool fails: the newlines are rejected as control characters.

Pick the window from the user's request and list the top-level transcripts:

```bash
find ~/.claude/projects -name '*.jsonl' -newermt '<YYYY-MM-DD>' -not -path '*/subagents/*' | sort
```

For each file, pull the user's own text:

```jq
select(.type=="user")
| (.message.content) as $c
| (if ($c|type)=="string" then $c else ($c|map(select(.type=="text")|.text)|join("\n")) end) as $t
| select($t != null and ($t|length) > 0)
| select($t|startswith("<") | not)
| select($t|test("system-reminder|tool_use_id") | not)
| "=== \($f) \(.timestamp // "")\n\($t)"
```

`startswith("<")` drops slash-command invocations, local-command output, and injected reminders, which are wrapped in tags. Track skipped messages separately if the user cares which slash commands they run — the command name is in the `<command-name>` tag.

Then condense: group by session, truncate each message past ~600 characters, and note the truncated length. That takes a few weeks down to something readable in one pass.

## What is signal

- **Skill invocations show up as user messages** beginning `Base directory for this skill: <path>` followed by the whole SKILL.md body. Count these by path — they show which skills are actually load-bearing — but exclude their body text from any keyword search, or the skill's own instructions swamp the results.
- **Repeated ad-hoc request shapes.** The same request phrased freshly each session is the strongest skill candidate: the user is re-typing instructions that could live in a file.
- **Explicit forward-looking asks.** "In the future, when working on X with you, what would be the best way to…" is a direct request for a durable practice. Find the answer given that session and check whether it ever got written down.
- **Corrections.** Grep for pushback, but expect a low hit rate and expect skill text to dominate the matches. Absence of corrections is itself a finding.
- **Tool mix.** Count `tool_use` names from assistant messages. A lopsided mix (all Bash, no Grep) or heavy use of one MCP server points at where the friction is.
- **Repeat failures across sessions.** The same error resurfacing weeks apart means the fix never made it into config.

Interrupts followed by "sorry, misinput" are not signal.

## Reporting

Lead with the patterns and the evidence for each: how many sessions, what the request looked like, what the user then did with the answer. Then propose candidate skills, and say for each what it would contain. Ask which to write before writing anything — a skill the user did not ask for is context cost on every future session.

## Writing the result

Skills go in `~/dev/dotfiles/shared/claude/skills/<name>/SKILL.md`; each subdirectory becomes a skill with no extra wiring. Global rules go in `shared/claude/claude.md`, settings in `shared/claude/default.nix`. See the `dotfiles` skill for the rebuild procedure — nothing takes effect until a rebuild.

Prefer folding a fact into an existing skill over creating a new one. Repo-specific practices belong in that repo's `CLAUDE.md` or `.claude/skills/`, not here.
