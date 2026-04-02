---
name: investigate
description: Investigate feature and produce a grooming-ready investigation document
disable-model-invocation: true
context: fork
agent: Plan
argument-hint: [ticket-or-id] [details] [desired-outcomes]
---

Investigate a feature for this project.

## Input

- **Feature:** $0
- **Details:** $1
- **Desired outcomes:** $2

## Jira context

Feature ticket:
!`acli jira workitem view $0 --fields summary,description,status,issuetype 2>/dev/null | head -c 4000 || echo "No Jira ticket for $0 - using details above."`

Related tickets:
!`acli jira workitem search --jql "parent = $0 OR issuekey in linkedIssuesOf($0) ORDER BY created DESC" --fields summary,status,issuetype 2>/dev/null | head -c 2000 || echo "No linked tickets found or ACLI not configured."`

## Instructions

1. Read the Jira context and feature details above.
2. Scan the codebase for relevant areas - patterns, modules, tests, config.
3. Ask 3-5 clarifying questions before proceeding. Do not assume.
4. Then produce `INVESTIGATION-$0.md` for the project root with these sections:
   - **Context** - ticket ref, date
   - **Requirements** - extracted from feature details + desired outcomes
   - **Current State** - what exists in the codebase today, reference specific files
   - **Proposed Approach** - simplest viable strategy, enough detail for grooming
   - **Alternatives Considered** - 1-2 with brief rationale for rejection
   - **Risks / Open Questions** - technical risks, unknowns, dependencies
   - **POC Scope** - what the POC covers/excludes, suggest a `poc/$0` branch
   - **Suggested Tickets** - table with #, Title, Description, Size (S/M/L)
   - **Notes** - additional context, links

## Rules

- Stick to feature requirements. Adjacent improvements go under Notes only.
- Be specific - reference actual file paths and patterns from the codebase.
- Do not create or modify any files. Propose content only.
- Jira is read-only. Never run create, edit, delete, or transition commands.
