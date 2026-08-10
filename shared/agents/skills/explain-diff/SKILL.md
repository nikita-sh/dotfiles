---
name: explain-diff
description: Explain what a change does and why, grouped by intent rather than by file. Use when handed a PR link, a branch, or a pasted diff and asked what it does, what it is for, why it was made, or to be walked through it. Explanation, not review — for defects use /code-review.
---

# Explaining a diff

Success is that a reader who has never seen the ticket can state what the change accomplishes and why, from your output alone. You are not hunting for defects. A short list of things you could not explain belongs at the end, but the body is explanation.

## Establish the range first

The first line of the output names the range you compared and the command that produced it. An explanation built on the wrong range describes work the reader is not looking at, and the reader has no way to notice.

Resolve the input in this order:

**A PR URL or number.** `gh pr diff <n>` for the change, and `gh pr view <n> --json title,body,baseRefName,headRefName,commits` for the stated intent. Check `baseRefName`: when the base is not the repository's default branch, this PR sits on top of another one, and only the diff against that base belongs to it.

**A repository with no argument.** Diff the checked-out branch against its merge base with the default branch — `git diff $(git merge-base HEAD origin/<default>)...HEAD`. Bare `git diff` and `git diff --staged` show only uncommitted work, which is almost never what "this change" means. If the working tree is dirty, say so, and say whether you included it.

**An explicit range or SHA.** Use it as given.

**A pasted diff.** Take it as given. Without the repository you cannot read surrounding code, so say which explanations are limited to what the hunks themselves show.

When the request is ambiguous between two of these, pick one and say which. The range line makes a wrong pick cheap to correct; a question costs a round trip.

## Recover the intent

Read the commit messages, the PR body, and any linked ticket before the diff itself — `gh issue view` for a GitHub issue, the Linear tools for a Linear key. They usually state the goal in a form no diff can.

Then read the code around the change for what the hunks cannot explain alone: the type a new field joins, the callers of a function whose signature moved, the invariant a new constraint enforces.

When the reason for a change is not recoverable from the diff, the commits, the ticket, or the surrounding code, say the reason is unstated. Do not supply a plausible one. A confident invented rationale is the worst thing this skill can produce, because it reads exactly like a recovered one.

Separate what the change does from what it enables. A migration adding a nullable column does nothing by itself; its purpose lives in the code that will read it. Say which of the two you are describing.

## Group by intent

Group hunks by what they accomplish, not by file or directory. One file often spans groups, and one group often spans many files. Name each group by the thing it achieves rather than by the mechanism it uses.

Order the groups: the change that motivates the work first, then what depends on it, then mechanical fallout. Mechanical fallout — generated types, build file dependencies, import churn, a rename propagated across call sites — gets one line naming what it is and what it followed from. Readers skip it, and space spent there buries the load-bearing change.

Tests are usually their own group. Say what behaviour they pin, since that is often the clearest available statement of the intended contract.

## Output

The range line. A short paragraph on the overall goal and where the why came from — ticket, commit message, or unstated. Then a paragraph per group naming its files, covering what it does and how it serves the goal.

Close with what you could not explain: a hunk with no apparent connection to the goal, two parts that appear to contradict each other, a case the change looks like it does not handle. Phrase these as questions and keep the list short. State that this is not a review, and that `/code-review` is what finds defects.

Scale the body to the number of distinct intents, not to the line count. A diff touching many files for one reason is one group.

When the diff is large, or the user asks for a file, write the same content to `/tmp/agent/<pr-number-or-branch>-explained.md` and give the path. Check the path is free first and pick another name if it is taken.
