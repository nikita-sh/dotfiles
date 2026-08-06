---
name: review-feedback
description: Triage code-review feedback item by item — restate each claim in plain words, verify it against the code, give a verdict with reasoning, then plan the subset worth doing. Use whenever feedback or a critique arrives, pasted or by link, however it is phrased — "what's the solution to this feedback", "how can we fix this", "please fix this", "plan a solution to the following", "this feedback doesn't make sense", "put this in simpler words", or a bare pasted reviewer comment with no question at all.
---

# Triaging review feedback

The feedback arrives as pasted text, as a link, or as prose with no citations at all. Whatever the form, the user wants a judgement on each item before any code changes. Some items will be wrong, some are real but belong in a later ticket, and some are best answered with a comment rather than a change.

## Intake

**Pasted text.** Often Codex output: a title, a `Resolved/Ignored` line, and a `file:line` citation with prose. Take the blocks as given.

**A GitHub PR or comment link.** Fetch it rather than asking the user to paste. `gh pr view <n> --comments` for the conversation, `gh api repos/{owner}/{repo}/pulls/{n}/comments` for inline review comments with their file and line, and `gh pr view <n> --json reviews` for review bodies. A link to a single comment carries its id in the fragment — fetch that comment specifically rather than triaging the whole thread. Automated CI comments posted to the PR count as feedback too, and often carry the machine-readable detail the prose summary drops.

**A Linear issue or comment link.** Use the Linear MCP tools to pull the issue and its comments. Feedback in a ticket is frequently a decision or a scope question rather than a code defect, so separate those out before triaging.

**A Slack thread link.** The user usually pastes the transcript. If a Slack tool is available, fetch the thread; otherwise ask for the paste rather than guessing at content behind the link.

**Prose with no citations.** Locate the code yourself before judging, and state which file and line you decided the item refers to. Getting the referent wrong makes the whole verdict meaningless, so if a claim could plausibly point at more than one place, say so and ask rather than picking.

When fetching produces more items than the user pointed at, triage what they asked about and list the rest by title so they can pull any of them in.

## Do not start editing

Number the items and hand back verdicts first. The user replies by picking a subset ("fix 2, 5 and 3"), and often overrules a verdict. Editing before that wastes work on items they were going to drop.

## Verify before judging

Read the cited `file:line` and the surrounding code. Reviewers describe code that has since changed, misread which module owns something, and assert invariants that the types do not actually enforce. Check the claim, not the confidence of the claim.

When the claim is about something the code cannot show on its own — whether a migration is needed, whether a field is used by a consumer outside the repo, whether a duplicated query predates the change — say what you checked, what you could not check, and what would settle it. Do not resolve it by guessing.

## Restate before verifying

Lead each item with one sentence in plain words: what the reviewer says is wrong, and what they say goes wrong because of it. Reviewer prose compresses a chain of reasoning into dense clauses, and the item cannot be judged — or argued with — until that chain is spelled out.

Name the concrete failure the item implies: which call, with which input, producing which wrong result. An item you cannot restate that way is either not a defect or not yet understood, and saying which is itself the verdict.

Keep the reviewer's own file and symbol names in the restatement. Paraphrasing them away makes the item hard to match back against the original comment when replying to the reviewer.

## Verdicts

Give each item one of:

- **Valid** — the defect is real. State the fix and its blast radius.
- **Invalid** — the claim does not hold. Say specifically why, citing what you read. A reviewer being wrong is a normal outcome.
- **Pre-existing** — real, but not introduced by this change. Say so explicitly; it changes whether it belongs in this PR.
- **Out of scope** — real and new, but the fix belongs to another owner or another ticket. Name the owner or ticket if the code says who it is.
- **Comment instead** — the concern is about intent that the code does not convey. Propose the comment wording, and make it explain the constraint or the tradeoff rather than restating the code.

## The plan

Once the user picks a subset, order the work so that anything touching a shared type or module boundary comes before the changes that depend on it. Call out any item whose fix would collide with another, and any that needs a build or test run to confirm rather than to check.

Verify with the repo's own loop before reporting anything fixed. In a Haskell repo that means compile status and the specs covering the touched modules, not a read-through of the diff.
