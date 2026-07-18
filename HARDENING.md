<!-- markdownlint-disable -->

# Hardening Report: kubescape--github-action/v3.0.1-fix

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **kubescape--github-action/v3.0.1-fix** was hardened automatically. 0 finding(s) were identified and resolved across 1 iteration(s).

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all three finding types across 5 workflow files:

1. script-injection (release.yaml): Moved `${{ github.repository }}` from the run: shell string into the step's env: block as REPOSITORY, then referenced it as "${REPOSITORY}" in the shell script.

2. github-env-injection (release.yaml): Added sanitization using `printf '%s' "${VAR}" | tr -d '\n\r'` before writing LATEST, CURRENT, and RELEASE values to $GITHUB_ENV.

3. unpinned-uses (all 5 workflow files): Pinned all mutable action references to full 40-character commit SHAs with tag comments: actions/checkout@v3→f43a0e5ff2bd294095638e18286ca9a3d1956744, tj-actions/changed-files@v35→039afcd1024c210363c9d3fc8fd07e1f3fcf2867, kubescape/github-action@main→7d90c1f159f02df1e3c79f839eeabe42ea30d4e3, peter-evans/create-pull-request@v4→38e0b6e68b4c852a5500a94740f0e535e0d7ba54, HollowMan6/sarif4reviewdog@v1.0.0→70fd54da0c00b0e4b807de395cc60b42e34c5453, github/codeql-action/upload-sarif@v2→b8d3b6e8af63cde30bdc382c0bc28114f4346c88. softprops/action-gh-release was already pinned and left unchanged.

