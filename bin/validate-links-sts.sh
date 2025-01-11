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
declare -r CSV_DELIMITER=","
declare -r CSV_QUOTE="\""
declare -r TAB_CHAR=$'\t'

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
# BOM (Byte Order Mark)
#
# The BOM is a Unicode character used to signal the byte order of a text file or
# stream. It is encoded at the beginning of the file or stream and is used to
# indicate the endianness of the text. The BOM is optional for UTF-8, but may be
# included at the start of encoded data as an indication that the text stream is
# Unicode and to identify the encoding scheme used.
# ------------------------------------------------------------------------------

function bom() {
  echo -ne '\xEF\xBB\xBF'
}

# ------------------------------------------------------------------------------
# Validate Links
# ------------------------------------------------------------------------------

function extract_links() {
  curl -s "${URL}" | sed -n '/<table[^>]*id="'"${TABLE_ID}"'"/,/<\/table>/p' | sed -n 's/.*<td[^>]*>\(http[^<]*\)<\/td>.*/\1/p'
}

function csv_string() {
  local -r text="${1}"
  local -r escaped="${text//\"/\"\"}"
  # If the string starts with any problematic character in Excel (so that
  # Excel would interpret it as a formula), add a tab in front of it.
  # This applies to the following leading characters: `=`, `+`, `-`, `@`.
  if [[ "${escaped}" =~ ^[=+-@] ]]; then
    echo -e "${CSV_QUOTE}${TAB_CHAR}${escaped}${CSV_QUOTE}"
  else
    echo "${CSV_QUOTE}${escaped}${CSV_QUOTE}"
  fi
}

# Get the host from a URL.
# Also strips any leading 'www' from the beginning.
function get_host_from_url() {
  local -r url="${1}"
  local host
  host="$(echo "${url}" | sed -n 's/https\?:\/\/\([^\/]*\).*/\1/p')"
  # Remove leading 'www.' from the host.
  host="${host//www./}"
  echo "${host}"
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

# Get all titles of a page.
#
# While normally only one `<title>` element is present, this function is
# intended to provide a list of all `<title>` elements as observed on some
# processed pages.
function get_titles() {
  local -r link="${1}"
  curl -s "${link}" | sed -n 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/p'
}

# Get the first title of a page.
#
# This function is intended to provide the first `<title>` element of a page.
# Any empty `<title>` element is skipped, and the next one is considered.
# If all `<title>` elements are empty, the URL is returned (shortened).
function get_first_non_empty_title_or_url() {
  local -r link="${1}"
  local title
  title="$(get_titles "${link}" | sed '/^$/d' | head -n 1)"
  if [[ -z "${title}" ]]; then
    get_host_from_url "${link}"
  else
    echo "${title}"
  fi
}

function validate_links() {
  local file_name="${1}"

  local links
  mapfile -t links < <(extract_links)

  info "Validating ${#links[@]} links..."

  # First writing to a temporary file to later handle the `file_name` argument.
  local tmp_file
  tmp_file="$(mktemp)"

  # Write BOM to the file.
  bom >"${tmp_file}"
  echo "URL${CSV_DELIMITER}Status${CSV_DELIMITER}Effective URL${CSV_DELIMITER}Title" >>"${tmp_file}"

  local status_code
  local effective_link
  local raw_title
  local title

  for link in "${links[@]}"; do
    status_code="$(curl -s -o /dev/null -w "%{http_code}" "${link}")"
    effective_link="$(curl -s -L -o /dev/null -w "%{url_effective}" "${link}")"
    raw_title="$(get_first_non_empty_title_or_url "${effective_link}")"
    title="$(replace_entities "${raw_title}")"

    info "Validated: ${link} (${status_code}) -> ${effective_link} (${title})"

    echo "$(csv_string "${link}")${CSV_DELIMITER}${status_code}${CSV_DELIMITER}$(csv_string "${effective_link}")${CSV_DELIMITER}$(csv_string "${title}")" >>"${tmp_file}"
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
