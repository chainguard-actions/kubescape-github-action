<!-- markdownlint-disable -->

# Hardening Report: kubescape--github-action/v3.0.1-fix

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **kubescape--github-action/v3.0.1-fix** was hardened automatically. 0 finding(s) were identified and resolved across 2 iteration(s).

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed all unpinned action references across 5 workflow files by replacing mutable tags/branches with full 40-character commit SHAs (with tag comments for readability). Fixed script injection in release.yaml by replacing `${{ github.repository }}` in the shell `run:` block with the pre-set `$GITHUB_REPOSITORY` environment variable. Actions pinned: actions/checkout@v3, tj-actions/changed-files@v35, kubescape/github-action@main, peter-evans/create-pull-request@v4, HollowMan6/sarif4reviewdog@v1.0.0, github/codeql-action/upload-sarif@v2. The softprops/action-gh-release reference in release.yaml was already pinned to a SHA.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed github-env-injection in .github/workflows/release.yaml: All three externally-controlled values written to $GITHUB_ENV are now sanitized before use. LATEST and CURRENT (from update.sh, sourced from git tag names of the external kubescape/kubescape repo and Dockerfile content) are sanitized via `printf '%s' "${VAR}" | tr -d '\n\r'` into safe_latest and safe_current. RELEASE (from git tag names of the cloned $GITHUB_REPOSITORY) is similarly sanitized into safe_release. This prevents an attacker who controls tag names in the upstream repository from injecting arbitrary environment variables into subsequent workflow steps via newline characters.

