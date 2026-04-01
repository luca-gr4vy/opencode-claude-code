---
description: Investigate feature (token-optimized)
agent: plan
---

Investigate a feature for this project.

## Input

- **Feature:** $1
- **Details:** $2
- **Desired outcomes:** $3

## Jira context

Feature ticket:
!`acli jira workitem view $1 --fields summary,description,status,issuetype 2>/dev/null | head -c 4000 || echo "No Jira ticket for $1 - using details above."`

Related tickets:
!`acli jira workitem search --jql "parent = $1 OR issuekey in linkedIssuesOf($1) ORDER BY created DESC" --fields summary,status,issuetype 2>/dev/null | head -c 2000 || echo "No linked tickets found or ACLI not configured."`

## Instructions

1. Read the Jira context and feature details above.
2. Scan the codebase for relevant areas - patterns, modules, tests, config.
3. Ask 3-5 clarifying questions before proceeding. Do not assume.
4. Then research and produce `INVESTIGATION-$1.md` for the project root with these sections:
   - **Context** - ticket ref, date
   - **Requirements** - extracted from feature details + desired outcomes
   - **Current State** - what exists in the codebase today, reference specific files
   - **Proposed Approach** - simplest viable strategy, enough detail for grooming
   - **Alternatives Considered** - 1-2 with brief rationale for rejection
   - **Risks / Open Questions** - technical risks, unknowns, dependencies
   - **POC Scope** - what the POC covers/excludes, suggest a `poc/$1` branch
   - **Suggested Tickets** - table with #, Title, Description, Size (S/M/L)
   - **Notes** - additional context, links

## Rules

- Stick to feature requirements. Adjacent improvements go under Notes only.
- Be specific - reference actual file paths and patterns from the codebase.
- Do not create or modify any files. Propose content only.
- Jira is read-only. Never run create, edit, delete, or transition commands.
