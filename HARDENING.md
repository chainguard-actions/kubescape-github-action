<!-- markdownlint-disable -->

# Hardening Report: kubescape--github-action/v3.0.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **kubescape--github-action/v3.0.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files reference actions using mutable tags or branch names instead of full 40-character commit SHAs, making them vulnerable to supply-chain attacks.

example-fix-commit.yaml: actions/checkout@v3, tj-actions/changed-files@v35, kubescape/github-action@main, peter-evans/create-pull-request@v4
example-fix-pr-review.yaml: actions/checkout@v3, tj-actions/changed-files@v35, kubescape/github-action@main, HollowMan6/sarif4reviewdog@v1.0.0
example-scan-image.yaml: actions/checkout@v3, kubescape/github-action@main, github/codeql-action/upload-sarif@v2
example-scan.yaml: actions/checkout@v3, kubescape/github-action@main, github/codeql-action/upload-sarif@v2
release.yaml: actions/checkout@v3, peter-evans/create-pull-request@v4

Locations:

- `.github/workflows/example-fix-commit.yaml:14`
- `.github/workflows/example-fix-commit.yaml:19`
- `.github/workflows/example-fix-commit.yaml:20`
- `.github/workflows/example-fix-commit.yaml:27`
- `.github/workflows/example-fix-pr-review.yaml:12`
- `.github/workflows/example-fix-pr-review.yaml:19`
- `.github/workflows/example-fix-pr-review.yaml:20`
- `.github/workflows/example-fix-pr-review.yaml:29`
- `.github/workflows/example-scan-image.yaml:11`
- `.github/workflows/example-scan-image.yaml:12`
- `.github/workflows/example-scan-image.yaml:28`
- `.github/workflows/example-scan.yaml:11`
- `.github/workflows/example-scan.yaml:12`
- `.github/workflows/example-scan.yaml:22`
- `.github/workflows/release.yaml:19`
- `.github/workflows/release.yaml:28`

### script-injection (severity: high)

Sub-rule (a): In release.yaml, the run: block directly interpolates the GitHub Actions expression `${{ github.repository }}` inside a shell command string. This allows the value to be interpreted by the shell before quoting can occur. Offending line: `git clone https://github.com/${{ github.repository }} github-action; cd github-action`

Locations:

- `.github/workflows/release.yaml:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed all 5 workflow files:

1. example-fix-commit.yaml: Pinned actions/checkout@v3, tj-actions/changed-files@v35, kubescape/github-action@main, peter-evans/create-pull-request@v4 to full commit SHAs.

2. example-fix-pr-review.yaml: Pinned actions/checkout@v3, tj-actions/changed-files@v35, kubescape/github-action@main, HollowMan6/sarif4reviewdog@v1.0.0 to full commit SHAs.

3. example-scan-image.yaml: Pinned actions/checkout@v3, kubescape/github-action@main, github/codeql-action/upload-sarif@v2 to full commit SHAs.

4. example-scan.yaml: Pinned actions/checkout@v3, kubescape/github-action@main, github/codeql-action/upload-sarif@v2 to full commit SHAs.

5. release.yaml: Pinned actions/checkout@v3 and peter-evans/create-pull-request@v4 to full commit SHAs. Fixed script-injection by moving ${{ github.repository }} into the step's env block as GH_REPOSITORY and referencing it as "$GH_REPOSITORY" in the shell command.

