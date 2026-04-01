---
description: Validate investigation (token-optimized)
agent: build
---

Validate the investigation document for feature `$1`. $2

## Source

@INVESTIGATION-$1.md

## Jira context

Feature ticket:
!`acli jira workitem view $1 --fields summary,description,status,issuetype 2>/dev/null | head -c 4000 || echo "No Jira ticket for $1 - validate against the document's stated requirements."`

Related tickets:
!`acli jira workitem search --jql "parent = $1 OR issuekey in linkedIssuesOf($1) ORDER BY created DESC" --fields summary,status,issuetype 2>/dev/null | head -c 2000 || echo "No linked tickets found or ACLI not configured."`

## Instructions

1. Read `INVESTIGATION-$1.md` and the Jira context above.
2. Scan the codebase to verify every claim in "Current State" - are paths real? Patterns accurate? Anything missed?
3. Challenge each section:
   - **Requirements** - complete vs. Jira ticket? Missing or misinterpreted?
   - **Current State** - accurate? Missed modules, tests, config?
   - **Proposed Approach** - simplest path? Leverages existing patterns? Hidden complexity?
   - **Alternatives** - right ones considered? Best one chosen?
   - **Risks** - missing edge cases, failure modes, dependencies?
   - **POC Scope** - too ambitious or too narrow? Proves the core hypothesis?
   - **Tickets** - well-scoped? Missing tickets? Reasonable sizes? Logical order?
4. Flag scope creep and unstated assumptions.
5. Edit `INVESTIGATION-$1.md` directly:
   - Inline corrections marked with `<!-- REVISED: reason -->`
   - Keep original content visible (strikethrough or "Previously" note)
   - Append a `## Validation Log` with: date, findings checklist, 1-2 sentence summary
   - Suggest a `poc/$1` branch if not already mentioned

## Rules

- Challenge against feature requirements only - not what you think they should be.
- Cite evidence: reference actual files/lines when challenging a claim.
- Be aggressive but fair. If something is solid, say so and move on.
- Jira is read-only. Never run create, edit, delete, or transition commands.
- Do not commit the file.
