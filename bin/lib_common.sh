#!/usr/bin/env bash
###
### A file to share common code between alias commands.
###
### Usage:
###
###   SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
###   declare -r SCRIPT_DIR
###   source "${SCRIPT_DIR}/lib_common.sh"
###

# Guard variable to prevent multiple imports
if [[ -n "${LIB_COMMON_SH_INCLUDED}" ]]; then
  return
fi
LIB_COMMON_SH_INCLUDED=1

# Provide option to trigger debug output with different verbosity levels.
declare -ri DEBUG=${DEBUG:-0}

# ------------------------------------------------------------------------------
# Bash Options
# ------------------------------------------------------------------------------

set -o errexit  # abort on nonzero exit status
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes
### Call with `DEBUG=2 alias.sh <file>` to enable verbose debug output
if ((DEBUG > 1)); then
  set -o xtrace # show expanded commands
else
  set +o xtrace # do not show expanded commands
fi

# ------------------------------------------------------------------------------
# Get Script Information
#
# A set of functions to get information about the script.
# Note, that ${0} resolves the the script using this library, as, in
# contrast to BASH_SOURCE[0], is not affected by sourcing.
#
# References:
#   - https://stackoverflow.com/a/35006457
#   - https://stackoverflow.com/a/29835459/45375
# ------------------------------------------------------------------------------

# Get the script name (including extension).
function get_script_name() {
  echo "${0##*/}"
}

# ------------------------------------------------------------------------------
# Logging
#
# All logging functions to output information to STDERR. STDERR is preferred,
# as it is not affected by the output redirection of the script, thus, the
# desired standard output can be redirected to a file or another command.
#
# References:
#   - https://gkarthiks.github.io/quick-commands-cheat-sheet/bash_command.html
#   - https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124
# ------------------------------------------------------------------------------

function debug() {
  if ((DEBUG > 0)); then
    if [[ -t 2 ]]; then
      echo -e "\033[0;90m[DEBUG] ${*}\033[0m" >&2
    else
      echo "[DEBUG] ${*}" >&2
    fi
  fi
}

function info() {
  echo "[INFO] ${*}" >&2
}

function error() {
  if [[ -t 2 ]]; then
    echo -e "\033[1;31m[ERROR] ${*}\033[0m" >&2
  else
    echo "[ERROR] ${*}" >&2
  fi
}

# ------------------------------------------------------------------------------
# General Output
# ------------------------------------------------------------------------------

# Prints a help message and exits. The exit code is either 0, if no reason is
# given, or 1, if a reason is provided, assuming that the help message was
# printed due to an error.
#
# If two parameters are given, the first denotes a failure reason to print.
# If only one parameter is given, it is assumed to be the help text.
function output_help_and_exit() {
  local help_text_or_failure="${1:-}"
  local help_text="${2:-}"
  local failure=""

  if [[ -z "${help_text}" ]]; then
    help_text="${help_text_or_failure}"
  else
    failure="${help_text_or_failure}"
  fi

  if [[ -n "${failure}" ]]; then
    error "${failure}"
    echo ""
  fi

  echo "${help_text}"

  [[ -n "${failure}" ]] && exit 1 || exit 0
}
