---
name: pin-dep
description: Update dependency version with lockfile focus and sanity checks
disable-model-invocation: true
context: fork
agent: general-purpose
allowed-tools: Bash, Read, Edit, Write
argument-hint: [package-name] [target-version] [range?] [build-command?]
---

I need to update a dependency version in this repo.

Package name: $0
Target version: $1
Optional range (default ^$1): $2
Optional build command (default yarn build): $3

Here's where $0 is used in the project:

!`npm ls $0`

Requirements:

- This repo uses Yarn v1 lockfile.
- Update yarn.lock directly to the target version using yarnpkg.com registry metadata.
- Use dist.tarball + dist.shasum for the resolved URL and dist.integrity for integrity.
- Add or update a root "resolutions" entry in package.json only if the user requests it or if it is required to keep the lock from reverting.
- Keep edits minimal and preserve existing formatting.
- If this is a major bump, call out engine/runtime risks briefly.
- Pay attention if the package is used as transitive dependency in several parent packages and with different versions. It might break something. Check for breaking changes in that case and if it's fine bumping the major version in that case.
- Run `yarn install` after the lock update.
- Run the build command (default `yarn build`) after install.

Output:

- Check that the new version is present by running `npm ls` with the affected dependency name
- Minimal diff snippet of the lock entry and any resolutions change.
- Brief note on any dependency tree changes if obvious.
