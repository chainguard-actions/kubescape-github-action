<!-- markdownlint-disable -->

# Hardening Report: kubescape--github-action/v3.0.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **kubescape--github-action/v3.0.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files reference GitHub Actions using mutable tags or branch names instead of pinned full-length SHA commit hashes. This exposes the workflow to supply-chain attacks if the referenced action is compromised or its tag is moved.

Failing references:
- example-fix-commit.yaml: actions/checkout@v3, tj-actions/changed-files@v35, kubescape/github-action@main, peter-evans/create-pull-request@v4
- example-fix-pr-review.yaml: actions/checkout@v3, tj-actions/changed-files@v35, kubescape/github-action@main, HollowMan6/sarif4reviewdog@v1.0.0
- example-scan-image.yaml: actions/checkout@v3, kubescape/github-action@main, github/codeql-action/upload-sarif@v2
- example-scan.yaml: actions/checkout@v3, kubescape/github-action@main, github/codeql-action/upload-sarif@v2
- release.yaml: actions/checkout@v3, peter-evans/create-pull-request@v4

Locations:

- `.github/workflows/example-fix-commit.yaml:9`
- `.github/workflows/example-fix-commit.yaml:12`
- `.github/workflows/example-fix-commit.yaml:13`
- `.github/workflows/example-fix-commit.yaml:21`
- `.github/workflows/example-fix-pr-review.yaml:8`
- `.github/workflows/example-fix-pr-review.yaml:14`
- `.github/workflows/example-fix-pr-review.yaml:15`
- `.github/workflows/example-fix-pr-review.yaml:22`
- `.github/workflows/example-scan-image.yaml:9`
- `.github/workflows/example-scan-image.yaml:10`
- `.github/workflows/example-scan-image.yaml:19`
- `.github/workflows/example-scan.yaml:9`
- `.github/workflows/example-scan.yaml:10`
- `.github/workflows/example-scan.yaml:17`
- `.github/workflows/release.yaml:18`
- `.github/workflows/release.yaml:27`

### script-injection (severity: high)

Sub-rule (a): In release.yaml, the `run:` block directly interpolates a GitHub Actions expression into a shell command string. The expression `${{ github.repository }}` is embedded directly in a `git clone` command:

  git clone https://github.com/${{ github.repository }} github-action; cd github-action

Any `${{ ... }}` expression interpolated directly inside a `run:` block is a script-injection risk because the value is substituted into the shell command before the shell parses it, bypassing shell quoting. The fix is to use the `$GITHUB_REPOSITORY` environment variable instead (e.g., `git clone "https://github.com/$GITHUB_REPOSITORY"`).

Locations:

- `.github/workflows/release.yaml:22`

### github-env-injection (severity: high)

In release.yaml, the `run:` block writes three variables to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`):

1. `echo "latest=${LATEST}" >> $GITHUB_ENV` — LATEST is sourced from git tags of an external repository via update.sh.
2. `echo "current=${CURRENT}" >> $GITHUB_ENV` — CURRENT is read from the first line of the Dockerfile.
3. `echo "release=${RELEASE}" >> $GITHUB_ENV` — RELEASE is derived from git tags of the cloned repository.

None of these values are literals computed within the same run block. If any of these values contain newline characters (e.g., a maliciously crafted git tag), an attacker could inject additional key=value pairs into the runner's environment, potentially overwriting sensitive environment variables used by subsequent steps.

Locations:

- `.github/workflows/release.yaml:20`
- `.github/workflows/release.yaml:21`
- `.github/workflows/release.yaml:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

Fixed all 3 findings across 5 workflow files:

1. unpinned-uses: Pinned all action references to full commit SHAs in all 5 workflow files (example-fix-commit.yaml, example-fix-pr-review.yaml, example-scan-image.yaml, example-scan.yaml, release.yaml). Actions pinned: actions/checkout@v3→f43a0e5, tj-actions/changed-files@v35→039afcd, kubescape/github-action@main→7d90c1f, peter-evans/create-pull-request@v4→38e0b6e, HollowMan6/sarif4reviewdog@v1.0.0→70fd54d, github/codeql-action/upload-sarif@v2→b8d3b6e.

2. script-injection: In release.yaml, replaced `${{ github.repository }}` in the git clone command with the pre-set `$GITHUB_REPOSITORY` environment variable, eliminating the expression interpolation risk.

3. github-env-injection: In release.yaml, sanitized LATEST, CURRENT, and RELEASE values before writing to $GITHUB_ENV using `printf '%s' "${VAR}" | tr -d '\n\r'` to strip embedded newlines that could allow environment variable injection.

