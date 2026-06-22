#!/busybox/sh

# Checks if `string` contains `substring`.
#
# Arguments:
#   String to check.
#
# Returns:
#   0 if `string` contains `substring`, otherwise 1.
contains() {
  case "$1" in
    *$2*) return 0 ;;
    *) return 1 ;;
  esac
}

set -e

# Kubescape uses the client name to make a request for checking for updates
export KS_CLIENT="github_actions"

if [ -n "${INPUT_FRAMEWORKS}" ] && [ -n "${INPUT_CONTROLS}" ]; then
  echo "Framework and Control are specified. Please specify either one of them"
  exit 1
fi

if [ -z "${INPUT_FRAMEWORKS}" ] && [ -z "${INPUT_CONTROLS}" ] && [ -z "${INPUT_IMAGE}" ]; then
  echo "Scannign scope is not specified. Scanning all frameworks"
  INPUT_FRAMEWORKS="all"
fi


if [ -n "${INPUT_FRAMEWORKS}" ] && [ -n "${INPUT_IMAGE}" ] || [ -n "${INPUT_CONTROLS}" ] && [ -n "${INPUT_IMAGE}" ] ; then
  errmsg="Image and Framework / Control are specified. Kubescape does not support scanning both at the moment."
  errmsg="${errmsg} Please specify either one of them or neither."
  echo "${errmsg}"
  exit 1
fi

if [ -n "${INPUT_IMAGE}" ] && [ "${INPUT_FIXFILES}" = "true" ]; then
  errmsg="The run requests both an image scan and file fix suggestions. Kubescape does not support fixing image scan results at the moment."
  errmsg="${errmsg} Please specify either one of them or neither."
  echo "${errmsg}"
  exit 1
fi

# Split the controls by comma and concatenate with quotes around each control
if [ -n "${INPUT_CONTROLS}" ]; then
  controls=""
  set -f
  IFS=','
  set -- "${INPUT_CONTROLS}"
  set +f
  unset IFS
  for control in "$@"; do
    control=$(echo "${control}" | xargs) # Remove leading/trailing whitespaces
    controls="${controls}\"${control}\","
  done
  controls=$(echo "${controls%?}")
fi

output_formats="${INPUT_FORMAT}"
have_json_format="false"
if [ -n "${output_formats}" ] && contains "${output_formats}" "json"; then
  have_json_format="true"
fi

verbose=""
if [ -n "${INPUT_VERBOSE}" ] && [ "${INPUT_VERBOSE}" != "false" ]; then
  verbose="--verbose"
fi

should_fix_files="false"
if [ "${INPUT_FIXFILES}" = "true" ]; then
  should_fix_files="true"
fi

# If a user requested Kubescape to fix their files, but forgot to ask for JSON
# output, do it for them
if [ "${should_fix_files}" = "true" ] && [ "${have_json_format}" != "true" ]; then
  output_formats="${output_formats},json"
fi

output_file="${INPUT_OUTPUTFILE:-results}"

if [ -n "${INPUT_FAILEDTHRESHOLD}" ] && [ -n "${INPUT_COMPLIANCETHRESHOLD}" ]; then
  echo "Both failedThreshold and complianceThreshold are specified. Please specify either one of them or neither"
  exit 1
fi

# When a user requests to fix files, the action should not fail because the
# results exceed severity. This is subject to change in the future.

# Handle image scanning request
image_subcmd_args=""
scan_input="${INPUT_FILES:-.}"
echo "image is <${INPUT_IMAGE}>"
if [ -n "${INPUT_IMAGE}" ]; then

  # By default, assume we are not authenticated. This means we can pull public
  # images from the container runtime daemon
  image_arg="${INPUT_IMAGE}"

  if [ -n "${INPUT_REGISTRYUSERNAME}" ] && [ -n "${INPUT_REGISTRYPASSWORD}" ]; then
    # When trying to authenticate, we cannot assume that the runner has access
    # to an *authenticated* container runtime daemon, so we should always try
    # to pull images from the registry
    image_arg="registry://${image_arg}"
    image_subcmd_args="image_with_auth"
  else
    echo "NOTICE: Received no registry credentials, pulling without authentication."
    printf "Hint: If you provide credentials, make sure you include both the username and password.\n\n"
    image_subcmd_args="image_no_auth"
  fi

  # Override the scan input
  scan_input="${image_arg}"
  echo "Scan subcommand: image"
fi

# Build the kubescape scan command using positional parameters to avoid eval
# and shell injection. Each argument is passed as a separate word.
set -- kubescape scan

# Add image subcommand and auth options if scanning an image
if [ "${image_subcmd_args}" = "image_with_auth" ]; then
  set -- "$@" image \
    "--username=${INPUT_REGISTRYUSERNAME}" \
    "--password=${INPUT_REGISTRYPASSWORD}"
elif [ "${image_subcmd_args}" = "image_no_auth" ]; then
  set -- "$@" image
fi

# Add framework or control subcommand
if [ -n "${INPUT_FRAMEWORKS}" ]; then
  set -- "$@" framework "${INPUT_FRAMEWORKS}"
elif [ -n "${INPUT_CONTROLS}" ]; then
  set -- "$@" control "${controls}"
fi

# Add scan input (files or image)
set -- "$@" "${scan_input}"

# Add account/access-key/server options
if [ -n "${INPUT_ACCOUNT}" ]; then
  set -- "$@" --account "${INPUT_ACCOUNT}"
fi
if [ -n "${INPUT_ACCESSKEY}" ]; then
  set -- "$@" --access-key "${INPUT_ACCESSKEY}"
fi
if [ -n "${INPUT_SERVER}" ]; then
  set -- "$@" --server "${INPUT_SERVER}"
fi

# Add threshold options (mutually exclusive, already validated above)
if [ -n "${INPUT_FAILEDTHRESHOLD}" ]; then
  set -- "$@" --fail-threshold "${INPUT_FAILEDTHRESHOLD}"
fi
if [ -n "${INPUT_COMPLIANCETHRESHOLD}" ]; then
  set -- "$@" --compliance-threshold "${INPUT_COMPLIANCETHRESHOLD}"
fi

# Add severity threshold (skip when fixing files)
if [ -n "${INPUT_SEVERITYTHRESHOLD}" ] && [ "${should_fix_files}" = "false" ]; then
  set -- "$@" --severity-threshold "${INPUT_SEVERITYTHRESHOLD}"
elif [ -n "${INPUT_SEVERITYTHRESHOLD}" ] && [ -n "${INPUT_IMAGE}" ]; then
  # Image scans always apply severity threshold
  set -- "$@" --severity-threshold "${INPUT_SEVERITYTHRESHOLD}"
fi

# Add format and output file
set -- "$@" --format "${output_formats}" --output "${output_file}"

# Add verbose flag
if [ -n "${verbose}" ]; then
  set -- "$@" "${verbose}"
fi

# Add exceptions
if [ -n "${INPUT_EXCEPTIONS}" ]; then
  set -- "$@" --exceptions "${INPUT_EXCEPTIONS}"
fi

# Add controls config
if [ -n "${INPUT_CONTROLSCONFIG}" ]; then
  set -- "$@" --controls-config "${INPUT_CONTROLSCONFIG}"
fi

echo "Running: $*"
"$@"

if [ "$should_fix_files" = "true" ]; then
  kubescape fix --no-confirm "${output_file}.json"
fi
