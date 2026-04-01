# Global AI rules

## Style

- Be concise by default.
- Prefer bullet points.
- No long preambles.

## Coding output

- When proposing code changes, show a minimal diff or a small snippet.
- Do not rewrite unrelated code.
- If uncertain, ask at most 1 clarifying question.
- Prefer existing patterns in the project.
- After each chunk, STOP and output:
  1. what changed
  2. why
  3. what the next chunk will do
- If the plan is missing something or a decision is unclear: STOP and ask before proceeding.
- Prefer incremental changes that keep the project buildable/tests runnable at each step.

## Debugging format

When debugging, respond in this format:

1. Likely cause
2. How to confirm (1-2 quick checks)
3. Fix (minimal change)

## Data handling

- NEVER send proprietary source code, logs, secrets, internal URLs, or customer data to external tools.
- External tools (including MCP servers like Context7) may be used ONLY for public library/framework documentation lookups.
- If a request would require sharing code or internal details, summarize generically or ask for a redacted snippet.
- Before calling any MCP tool, show the exact query you will send and wait for confirmation.

## Context7 usage

- Allowed: library names, versions, public API questions, generic pseudocode.
- Forbidden: pasting code from this repo, stack traces, configs, tokens, internal endpoints.

## Tests

- Avoid mocks as much as possible
- Test actual implementation, do not duplicate logic into tests
