#!/usr/bin/env bash
###
### Validates links to "Stadtteilschulen" (StS) at
### https://gest-hamburg.de/stadtteilschulen/.
###
### Only links within a table with ID `tablepress-stadtteilschulen` are checked.
###
### Output is CSV formatted file with the following columns:
###
###   - URL: The original URL of the link.
###   - Status: The HTTP status code of the link.
###   - Redirect: The URL the original URL redirects to.
###   - Title: The `<title>` of the page the URL points to (also works for
###     `<title>` elements having attributes).
###
### The CSV applies the Excel dialect, thus, the delimiter is a semicolon, and
### the text is enclosed by double quotes (escaping is done by doubling double
### quotes).
###
### By default, the script outputs to STDOUT. If a file is provided as an
### argument, the output is written to that file.
###
### Requirements:
###   - curl
###   - sed

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
declare -r SCRIPT_DIR
# shellcheck source=./lib_common.sh
source "${SCRIPT_DIR}/lib_common.sh"

SCRIPT_NAME="$(get_script_name)"
declare -r SCRIPT_NAME

declare -r URL="https://gest-hamburg.de/stadtteilschulen/"
declare -r TABLE_ID="tablepress-stadtteilschulen"
declare -r CSV_DELIMITER=";"
declare -r CSV_QUOTE="\""

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

function show_help() {
  local -r failure="${1:-}"
  local -r help_text="\
Usage: ${SCRIPT_NAME} [-?|-h] [-f <file>]

Options:
  -?|-h   Show this help message
  -f      File to write the CSV output to ('-' for STDOUT; the default)

Examples:
    ${SCRIPT_NAME}
    ${SCRIPT_NAME} -h
    ${SCRIPT_NAME} -f results.csv
"
  output_help_and_exit "${failure}" "${help_text}"
}

# ------------------------------------------------------------------------------
# Validate Links
# ------------------------------------------------------------------------------

function extract_links() {
  curl -s "${URL}" | sed -n '/<table[^>]*id="'"${TABLE_ID}"'"/,/<\/table>/p' | sed -n 's/.*<td[^>]*>\(http[^<]*\)<\/td>.*/\1/p'
}

function escape_csv() {
  local -r text="${1}"
  echo "${text//\"/\"\"}"
}

# Replace given entities.
function replace_entities() {
  local -r text="${1}"
  local replaced="${text//&amp;/&}"
  replaced="${replaced//&lt;/<}"
  replaced="${replaced//&gt;/>}"
  replaced="${replaced//&quot;/\"}"
  replaced="${replaced//&nbsp;/ }"
  # 8211 is the Unicode code point for an en dash.
  replaced="${replaced//&#8211;/-}"
  echo "${replaced}"
}

function validate_links() {
  local file_name="${1}"

  local links
  mapfile -t links < <(extract_links)

  info "Validating ${#links[@]} links..."

  # First writing to a temporary file to later handle the `file_name` argument.
  local tmp_file
  tmp_file="$(mktemp)"

  echo "URL${CSV_DELIMITER}Status${CSV_DELIMITER}Effective URL${CSV_DELIMITER}Title" >"${tmp_file}"

  local status_code
  local effective_link
  local raw_title
  local title

  for link in "${links[@]}"; do
    status_code="$(curl -s -o /dev/null -w "%{http_code}" "${link}")"
    effective_link="$(curl -s -L -o /dev/null -w "%{url_effective}" "${link}")"
    raw_title="$(curl -s "${effective_link}" | sed -n 's/.*<title[^>]*>\([^<]]*\)<\/title>.*/\1/p')"
    title="$(replace_entities "${raw_title}")"

    info "Validated: ${link} (${status_code}) -> ${effective_link} (${title})"

    echo "${CSV_QUOTE}$(escape_csv "${link}")${CSV_QUOTE}${CSV_DELIMITER}${status_code}${CSV_DELIMITER}${CSV_QUOTE}$(escape_csv "${effective_link}")${CSV_QUOTE}${CSV_DELIMITER}${CSV_QUOTE}$(escape_csv "${title}")${CSV_QUOTE}" >>"${tmp_file}"
  done

  if [[ "${file_name}" == "-" ]]; then
    cat "${tmp_file}"
  else
    mv "${tmp_file}" "${file_name}"
  fi

  info "Validation completed."

  # Cleanup temporary files
  rm -f "${tmp_file}"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

function main() {
  local file_name="-"

  while getopts ":?f:h" opt; do
    case "${opt}" in
    f)
      file_name="${OPTARG}"
      ;;
    h)
      show_help
      ;;
    \?)
      # Trick to bypass getopts not supporting `-?` as a valid option.
      if [[ "${OPTARG}" == "?" ]]; then
        show_help
      else
        show_help "Unsupported option -${OPTARG}."
      fi
      ;;
    :)
      show_help "Option -${OPTARG} requires an argument."
      ;;
    *)
      show_help "Illegal option -${OPTARG}."
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Fail if there are any arguments left.
  if [[ "${#}" -gt 0 ]]; then
    show_help "Unexpected argument: ${1}"
  fi

  validate_links "${file_name}"
}

main "${@}"
