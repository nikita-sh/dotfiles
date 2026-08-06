---
name: pr-description
description: Write a concise PR description — overview, why, what changed, how it works, how to test. Use when asked to write, draft, fill in, or update a pull request description or body, or for a summary written for a PR.
---

# Writing a PR description

The reviewer's question is "what am I looking at, and what should I check". Everything in the description either answers that or comes out.

Invoke `writing-clearly-and-concisely` before drafting.

## Gather

Resolve the diff the way `explain-diff` does: a PR number through `gh pr diff <n>` and `gh pr view <n> --json title,body,baseRefName,commits`, or the checked-out branch against its merge base with the default branch. See that skill for the ambiguous intake cases.

Read the linked ticket for the requirement and the commit messages for decisions made along the way — a decision reversed mid-branch is usually worth a line in the description, since the final diff no longer shows the alternative.

Match the repository's title convention instead of guessing: `gh pr list --state merged --limit 10 --json title` shows whether titles carry a ticket key, a prefix, or neither.

## Structure

Use these headings, and drop any that would be empty rather than writing filler under it.

**Overview** — a few sentences on what the change does and who it affects, enough that a reviewer with no context knows what they are looking at.

**Why** — the problem or requirement, with the ticket linked. When the change rests on a constraint that is not visible in the code, state it here. That constraint is what reviewers dispute, and answering it up front saves a round trip.

**What changed** — one line per semantic group, naming the module or area. Grouped by intent, not by file. This is not a file inventory; the diff already lists files.

**How it works** — only the mechanism a reader cannot infer: a new invariant, a required ordering between two operations, a fallback path, or why a simpler-looking approach does not work. Drop the section when "What changed" already conveys it.

**Testing** — how the change was verified, in a couple of lines. Name the specs and any manual check. No checklists, and no test plan for tests you did not write.

Add a `Stacked on #<n>` line when the base is not the default branch, so the reviewer knows which part of the diff is theirs to read.

## What to leave out

Do not restate the diff in prose. Do not open sentences with "This PR" — say what the change does. Do not describe your own work as robust, comprehensive, clean, or thorough. Do not add a future-work section unless a TODO in the diff names a ticket. Do not keep a heading for symmetry when there is nothing to put under it.

## Publishing

Show the draft in the conversation and wait for approval before touching the PR. On approval, pipe the body rather than staging a temp file:

```
gh pr edit <n> --body-file - <<'EOF'
...
EOF
```

Then read it back with `gh pr view <n> --json body` and confirm what landed. When there is no PR yet, offer `gh pr create` with the same body.
