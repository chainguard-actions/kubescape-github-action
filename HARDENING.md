<!-- markdownlint-disable -->

# Hardening Report: kubescape--github-action/v3.0.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **kubescape--github-action/v3.0.5** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

entrypoint.sh builds a shell command string by interpolating user-controlled action inputs (INPUT_FRAMEWORKS, INPUT_CONTROLS, INPUT_FILES, INPUT_IMAGE, INPUT_REGISTRYUSERNAME, INPUT_REGISTRYPASSWORD, INPUT_ACCOUNT, INPUT_ACCESSKEY, INPUT_SERVER, INPUT_FORMAT, INPUT_OUTPUTFILE, INPUT_EXCEPTIONS, INPUT_CONTROLSCONFIG, INPUT_SEVERITYTHRESHOLD, INPUT_FAILEDTHRESHOLD, INPUT_COMPLIANCETHRESHOLD) unquoted into the `scan_command` variable, then executes it with `eval "${scan_command}"`. Because the inputs are not quoted when embedded in the command string, an attacker who controls any of these inputs can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks) to execute arbitrary commands. Rule (b): unquoted shell variable expansion of untrusted/user-controlled data. Offending line: `scan_command="kubescape scan ${image_subcmd} ${frameworks_cmd} ${controls_cmd} ${scan_input} ..."` followed by `eval "${scan_command}"`. A second `eval` on `fix_command` also interpolates the unquoted `${output_file}` (derived from `INPUT_OUTPUTFILE`).

Locations:

- `entrypoint.sh:155`
- `entrypoint.sh:159`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in entrypoint.sh by replacing the eval-based command construction with POSIX sh positional parameter accumulation. The original code built a `scan_command` string by interpolating unquoted user-controlled INPUT_* variables and executed it with `eval "${scan_command}"`, allowing shell metacharacter injection. The fix uses `set -- kubescape scan` followed by conditional `set -- "$@" --flag "${INPUT_VALUE}"` calls to safely append each argument as a separate quoted word, then executes with `"$@"` directly. The `kubescape fix` call at the end was also simplified to directly pass `"${output_file}.json"` without eval. All user-controlled inputs are now properly isolated as individual arguments, preventing injection of shell metacharacters.

