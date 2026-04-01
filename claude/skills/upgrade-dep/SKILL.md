---
name: upgrade-dep
description: Upgrade npm dependency with major version safety checks
disable-model-invocation: true
context: fork
agent: deep
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
argument-hint: [package-name] [target-version]
---

Upgrade the dependency `$1` to version `$2` in this project.

## Current state

!`npm ls $1 2>&1 || true`

## Instructions

Follow these phases in order. Do NOT skip phases.

### Phase 1: Gather context

1. Detect the package manager by checking which lockfile exists at the project root:
   - `yarn.lock` -> Yarn
   - `package-lock.json` -> npm
   - `pnpm-lock.yaml` -> pnpm
   - `bun.lock` -> Bun
2. Determine the currently installed version of `$1` from the `npm ls` output above.
3. Compare the major version of the current install vs `$2`.
   - If the major version differs, this is a major upgrade and you must run Phase 2.
   - Otherwise, skip Phase 2 and continue to Phase 3.

### Phase 2: Major upgrade research (only if major bump)

1. Fetch package metadata from `https://registry.npmjs.org/$1` to find the `repository` URL.
2. Fetch the official changelog or release notes. Try these sources via web fetch:
   - GitHub releases: `https://github.com/<owner>/<repo>/releases`
   - Raw CHANGELOG: `https://raw.githubusercontent.com/<owner>/<repo>/main/CHANGELOG.md`
   - Migration guide candidates: `MIGRATION.md`, `UPGRADING.md`, or `docs/migration*`
3. Use Context7 to look up migration guides and breaking changes for the target major version.
   - Resolve the library ID first.
   - Only send public package name and version information.
4. Search the codebase for actual usage of `$1` (imports, requires, config references) and map findings to breaking changes.
5. Produce a major-upgrade summary:
   - Breaking changes relevant to this project
   - Required code modifications
   - Risk assessment: safe / caution / risky
6. If risk is caution or risky: stop and ask for explicit user confirmation before proceeding.

### Phase 3: Apply the upgrade

1. Run the appropriate upgrade command:
   - Yarn: `yarn upgrade $1@$2` (or `yarn add $1@$2` when needed)
   - npm: `npm install $1@$2`
   - pnpm: `pnpm add $1@$2`
   - Bun: `bun add $1@$2`
2. If this is a monorepo, check all workspace packages and update each workspace that depends on `$1`.
3. If this is a major upgrade, apply code/config changes identified in Phase 2.
4. Re-run install to ensure the lockfile is consistent.

### Phase 4: Sanity checks

Read root `package.json` scripts and run checks in this order when script/command exists:

1. Install (`<pm> install`)
2. Lint (`lint`)
3. Format (`format` or `prettier`)
4. Build (`build`)
5. Test (`test`)
6. Dependency-specific checks when relevant

Dependency-specific checks guidance:

- TypeScript/compiler/tooling packages: run `npx tsc --noEmit` when available
- Linter/formatter packages: run the corresponding tooling scripts directly
- Framework/runtime packages: run app/package-level smoke checks if present

If a check fails:

- Diagnose and apply a minimal fix
- Re-run the failed check
- Continue sequence
- If still blocked after 3 attempts on the same issue, stop and report clearly

### Phase 5: Report

Provide a concise report with:

- Upgraded package and version change (from -> to)
- Upgrade type (major/minor/patch)
- Breaking changes found and applied (if major)
- Files modified
- Sanity checks run and pass/fail outcomes
- Remaining manual actions or warnings
