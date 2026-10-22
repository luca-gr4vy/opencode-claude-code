---
name: fix-node-vuln
description: Fix node package vulnerabilities (npm/pnpm/yarn)
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, WebFetch
argument-hint: [vuln-id] [package-name] [dependabot-alert-url?] [trivy-failure-url?]
---

Fix $0 in package $1 in this repo.

Vulnerability ID: $0
Package: $1
Optional dependabot alert URL: $2
Optional trivy failure URL: $3

## 1. Check for existing work

Before doing anything, check nobody already fixed this:

- `gh pr list --search "$0 $1" --state open`
- `git branch -a | grep -i "$1"`

If a matching PR/branch exists, stop and report it instead of duplicating work.

## 2. Detect package manager

- `test -f pnpm-lock.yaml` → pnpm
- `test -f yarn.lock` → yarn v1

## 3. Find the patched version

Use whichever source is already available, in this order (stop at the first that gives a clear "fixed in" version — don't redo work already given to you):

1. If $2 (dependabot alert URL) is given → fetch it, read the patched-version range directly.
2. Else if $3 (trivy failure URL) is given → fetch it, read the "Fixed Version" column.
3. Else run `pnpm audit` / `yarn audit` scoped to $1 — advisory output includes "patched versions".
4. For OS/library vulns not covered by an npm advisory, run the local trivy scan and read "Fixed Version":
   `trivy fs --format table --exit-code 1 --ignore-unfixed --vuln-type os,library --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL --skip-dirs example/vendor --db-repository us-docker.pkg.dev/gr4vy-admin/ghcr/aquasecurity/trivy-db --scanners vuln .`

Check where $1 is used with `npm ls $1` and confirm the current version in the lockfile.

## 4. Apply the fix (try in order)

1. `pnpm update $1` / `yarn upgrade $1` — minor/patch bump within the current semver range, no breaking-change risk. Try this first, including for transitive $1 (may just need `pnpm update` at the root to pull a patched nested version).
2. If that doesn't reach the patched version, a major version bump of $1 — check for breaking changes first.
3. Direct lockfile edit to the target version, using the package manager's own registry metadata (e.g. yarnpkg.com). Use `dist.tarball` + `dist.shasum` for the resolved URL and `dist.integrity` for integrity.
4. Root "overrides" (npm/pnpm) or "resolutions" (yarn) entry in package.json — last resort, or if the user asks for it, or needed to stop the lock reverting.
5. If none of the above are possible (no fix available upstream, override breaks the build, etc.): don't apply anything — suggest ignoring instead, with a clear reason:
   - Trivy-sourced: propose a `.trivyignore` entry for $0.
   - Dependabot-sourced: propose dismissing the alert in the GitHub UI.
   This is a suggestion for the user to approve, not something to apply automatically.

Notes:

- $1 may be a transitive dependency pulled in by multiple parents at different versions — check for breaking changes across all of them before bumping a shared major version.
- Keep edits minimal, preserve existing formatting.
- Call out engine/runtime risks briefly on major bumps.
- For `@gr4vy-react-native`, `--no-verify` on commit is fine for now (known broken hook, tracked separately).

## 5. Verify

- `pnpm install` / `yarn install`
- `pnpm build` / `yarn build`
- `pnpm test` / `yarn test` — if a `test` script exists in package.json
- `pnpm lint` / `yarn lint` — if a `lint` script exists in package.json
- `pnpm audit` / `yarn audit` — confirm $0 is no longer reported

**If audit still reports $0 after overrides/resolutions (step 4, tier 4):** move to tier 5 — report which tiers were tried, why each fell short, and propose the ignore/dismiss with a reason. Don't apply it without the user's OK.

## Output

- `npm ls $1` showing the new version
- `pnpm audit` / `yarn audit` result
- Minimal diff snippet of the lock entry and any overrides/resolutions change
- Brief note on dependency tree changes, if any
- Push a branch, open a PR referencing the dependabot alert/trivy failure, concise description, share the link, stop for review
  - Reference alerts by full URL (`[264](https://github.com/<owner>/<repo>/security/dependabot/264)`), never bare `#264` — GitHub autolinks `#N` to issue/PR N, not the alert. Same in commit messages.
  - If `gh pr create/edit` fails on `read:org` scope, use `gh api -X PATCH repos/<owner>/<repo>/pulls/<n> -F body=@file`.
